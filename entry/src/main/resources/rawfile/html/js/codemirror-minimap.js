import { Facet, combineConfig, StateField } from '@codemirror/state';
import { EditorView, ViewPlugin } from '@codemirror/view';
import crelt from 'crelt';
import { setDiagnosticsEffect, diagnosticCount, forEachDiagnostic } from '@codemirror/lint';
import { foldEffect, unfoldEffect, foldedRanges, language, highlightingFor } from '@codemirror/language';
import { highlightTree } from '@lezer/highlight';
import { TreeFragment } from '@lezer/common';

var __rest = (undefined && undefined.__rest) || function (s, e) {
    var t = {};
    for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p) && e.indexOf(p) < 0)
        t[p] = s[p];
    if (s != null && typeof Object.getOwnPropertySymbols === "function")
        for (var i = 0, p = Object.getOwnPropertySymbols(s); i < p.length; i++) {
            if (e.indexOf(p[i]) < 0 && Object.prototype.propertyIsEnumerable.call(s, p[i]))
                t[p[i]] = s[p[i]];
        }
    return t;
};
const Config = /*@__PURE__*/Facet.define({
    combine: (c) => {
        const configs = [];
        for (let config of c) {
            if (!config) {
                continue;
            }
            const { create, gutters } = config, rest = __rest(config, ["create", "gutters"]);
            configs.push(Object.assign(Object.assign({}, rest), { enabled: true, gutters: gutters
                    ? gutters.filter((v) => Object.keys(v).length > 0)
                    : undefined }));
        }
        return combineConfig(configs, {
            enabled: configs.length > 0,
            displayText: "characters",
            eventHandlers: {},
            showOverlay: "always",
            gutters: [],
        });
    },
});
const Scale = {
    // Multiply the number of canvas pixels
    PixelMultiplier: 2,
    // Downscale the editor contents by this ratio
    SizeRatio: 4,
    // Maximum width of the minimap in pixels
    MaxWidth: 120,
};

const Theme$1 = /*@__PURE__*/EditorView.theme({
    ".cm-minimap-overlay-container": {
        position: "absolute",
        top: 0,
        height: "100%",
        width: "100%",
        "&.cm-minimap-overlay-mouse-over": {
            opacity: 0,
            transition: "visibility 0s linear 300ms, opacity 300ms",
        },
        "&.cm-minimap-overlay-mouse-over:hover": {
            opacity: 1,
            transition: "visibility 0s linear 0ms, opacity 300ms",
        },
        "&.cm-minimap-overlay-off": {
            display: "none",
        },
        "& .cm-minimap-overlay": {
            background: "rgb(121, 121, 121)",
            opacity: "0.2",
            position: "absolute",
            right: 0,
            top: 0,
            width: "100%",
            transition: "top 0s ease-in 0ms",
            "&:hover": {
                opacity: "0.3",
            },
        },
        "&.cm-minimap-overlay-active": {
            opacity: 1,
            visibility: "visible",
            transition: "visibility 0s linear 0ms, opacity 300ms",
            "& .cm-minimap-overlay": {
                opacity: "0.4",
            },
        },
    },
});
const SCALE = Scale.PixelMultiplier * Scale.SizeRatio;
const OverlayView = /*@__PURE__*/ViewPlugin.fromClass(class {
    constructor(view) {
        this.view = view;
        this._isDragging = false;
        if (view.state.facet(Config).enabled) {
            this.create(view);
        }
    }
    create(view) {
        this.container = crelt("div", { class: "cm-minimap-overlay-container" });
        this.dom = crelt("div", { class: "cm-minimap-overlay" });
        this.container.appendChild(this.dom);
        // Attach event listeners for overlay
        this.container.addEventListener("mousedown", this.onMouseDown.bind(this));
        window.addEventListener("mouseup", this.onMouseUp.bind(this));
        window.addEventListener("mousemove", this.onMouseMove.bind(this));
        // Attach the overlay elements to the minimap
        const inner = view.dom.querySelector(".cm-minimap-inner");
        if (inner) {
            inner.appendChild(this.container);
        }
        // Initially set overlay configuration styles, height, top
        this.computeShowOverlay();
        this.computeHeight();
        this.computeTop();
    }
    remove() {
        if (this.container) {
            this.container.removeEventListener("mousedown", this.onMouseDown);
            window.removeEventListener("mouseup", this.onMouseUp);
            window.removeEventListener("mousemove", this.onMouseMove);
            this.container.remove();
        }
    }
    update(update) {
        const prev = update.startState.facet(Config).enabled;
        const now = update.state.facet(Config).enabled;
        if (prev && !now) {
            this.remove();
            return;
        }
        if (!prev && now) {
            this.create(update.view);
        }
        if (now) {
            this.computeShowOverlay();
            if (update.geometryChanged) {
                this.computeHeight();
                this.computeTop();
            }
        }
    }
    computeHeight() {
        if (!this.dom) {
            return;
        }
        const height = this.view.dom.clientHeight / SCALE;
        this.dom.style.height = height + "px";
    }
    computeTop() {
        if (!this._isDragging && this.dom) {
            const { clientHeight, scrollHeight, scrollTop } = this.view.scrollDOM;
            const maxScrollTop = scrollHeight - clientHeight;
            const topForNonOverflowing = scrollTop / SCALE;
            const height = clientHeight / SCALE;
            const maxTop = clientHeight - height;
            let scrollRatio = scrollTop / maxScrollTop;
            if (isNaN(scrollRatio))
                scrollRatio = 0;
            const topForOverflowing = maxTop * scrollRatio;
            const top = Math.min(topForOverflowing, topForNonOverflowing);
            this.dom.style.top = top + "px";
        }
    }
    computeShowOverlay() {
        if (!this.container) {
            return;
        }
        const { showOverlay } = this.view.state.facet(Config);
        if (showOverlay === "mouse-over") {
            this.container.classList.add("cm-minimap-overlay-mouse-over");
        }
        else {
            this.container.classList.remove("cm-minimap-overlay-mouse-over");
        }
        const { clientHeight, scrollHeight } = this.view.scrollDOM;
        if (clientHeight === scrollHeight) {
            this.container.classList.add("cm-minimap-overlay-off");
        }
        else {
            this.container.classList.remove("cm-minimap-overlay-off");
        }
    }
    onMouseDown(event) {
        if (!this.container) {
            return;
        }
        // Ignore right click
        if (event.button === 2) {
            return;
        }
        // If target is the overlay start dragging
        const { clientY, target } = event;
        if (target === this.dom) {
            this._dragStartY = event.clientY;
            this._isDragging = true;
            this.container.classList.add("cm-minimap-overlay-active");
            return;
        }
        // Updates the scroll position of the EditorView based on the
        // position of the MouseEvent on the minimap canvas
        const { clientHeight, scrollHeight, scrollTop } = this.view.scrollDOM;
        const targetTop = target.getBoundingClientRect().top;
        const deltaY = (clientY - targetTop) * SCALE;
        const scrollRatio = scrollTop / (scrollHeight - clientHeight);
        const visibleRange = clientHeight * SCALE - clientHeight;
        const visibleTop = visibleRange * scrollRatio;
        const top = Math.max(0, scrollTop - visibleTop);
        this.view.scrollDOM.scrollTop = top + deltaY - clientHeight / 2;
    }
    onMouseUp(_event) {
        // Stop dragging on mouseup
        if (this._isDragging && this.container) {
            this._dragStartY = undefined;
            this._isDragging = false;
            this.container.classList.remove("cm-minimap-overlay-active");
        }
    }
    onMouseMove(event) {
        if (!this._isDragging || !this.dom) {
            return;
        }
        event.preventDefault();
        event.stopPropagation();
        // Without an existing position, we're just beginning to drag.
        if (!this._dragStartY) {
            this._dragStartY = event.clientY;
            return;
        }
        const deltaY = event.clientY - this._dragStartY;
        const movingUp = deltaY < 0;
        const movingDown = deltaY > 0;
        // Update drag position for the next tick
        this._dragStartY = event.clientY;
        const canvasHeight = this.dom.getBoundingClientRect().height;
        const canvasAbsTop = this.dom.getBoundingClientRect().y;
        const canvasAbsBot = canvasAbsTop + canvasHeight;
        const canvasRelTopDouble = parseFloat(this.dom.style.top);
        const scrollPosition = this.view.scrollDOM.scrollTop;
        const editorHeight = this.view.scrollDOM.clientHeight;
        const contentHeight = this.view.scrollDOM.scrollHeight;
        const atTop = scrollPosition === 0;
        const atBottom = Math.round(scrollPosition) >= Math.round(contentHeight - editorHeight);
        // We allow over-dragging past the top/bottom, but the overlay just sticks
        // to the top or bottom of its range. These checks prevent us from immediately
        // moving the overlay when the drag changes direction. We should wait until
        // the cursor has returned to, and begun to pass the bottom/top of the range
        if ((atTop && movingUp) || (atTop && event.clientY < canvasAbsTop)) {
            return;
        }
        if ((atBottom && movingDown) ||
            (atBottom && event.clientY > canvasAbsBot)) {
            return;
        }
        // Set view scroll directly
        const scrollHeight = this.view.scrollDOM.scrollHeight;
        const clientHeight = this.view.scrollDOM.clientHeight;
        const maxTopNonOverflowing = (scrollHeight - clientHeight) / SCALE;
        const maxTopOverflowing = clientHeight - clientHeight / SCALE;
        const change = canvasRelTopDouble + deltaY;
        /**
         * ScrollPosOverflowing is calculated by:
         * - Calculating the offset (change) relative to the total height of the container
         * - Multiplying by the maximum scrollTop position for the scroller
         * - The maximum scrollTop position for the scroller is the total scroll height minus the client height
         */
        const relativeToMax = change / maxTopOverflowing;
        const scrollPosOverflowing = (scrollHeight - clientHeight) * relativeToMax;
        const scrollPosNonOverflowing = change * SCALE;
        this.view.scrollDOM.scrollTop = Math.max(scrollPosOverflowing, scrollPosNonOverflowing);
        // view.scrollDOM truncates if out of bounds. We need to mimic that behavior here with min/max guard
        const top = Math.min(Math.max(0, change), Math.min(maxTopOverflowing, maxTopNonOverflowing));
        this.dom.style.top = top + "px";
    }
    destroy() {
        this.remove();
    }
}, {
    eventHandlers: {
        scroll() {
            requestAnimationFrame(() => this.computeTop());
        },
    },
});
const Overlay = [Theme$1, OverlayView];

// TODO: renamed this file because something's weird with codemirror build
class LineBasedState {
    constructor(view) {
        this.map = new Map();
        this.view = view;
    }
    get(lineNumber) {
        return this.map.get(lineNumber);
    }
    set(lineNumber, value) {
        this.map.set(lineNumber, value);
    }
}

function computeLinesState(state) {
    var _a;
    if (!state.facet(Config).enabled) {
        return [];
    }
    const lines = [];
    const lineCursor = state.doc.iterLines();
    const foldedRangeCursor = foldedRanges(state).iter();
    let textOffset = 0;
    lineCursor.next();
    while (!lineCursor.done) {
        const lineText = lineCursor.value;
        let from = textOffset;
        let to = from + lineText.length;
        // Iterate through folded ranges until we're at or past the current line
        while (foldedRangeCursor.value && foldedRangeCursor.to < from) {
            foldedRangeCursor.next();
        }
        const { from: foldFrom, to: foldTo } = foldedRangeCursor;
        const lineStartInFold = from >= foldFrom && from < foldTo;
        const lineEndsInFold = to > foldFrom && to <= foldTo;
        if (lineStartInFold) {
            let lastLine = (_a = lines.pop()) !== null && _a !== void 0 ? _a : [];
            let lastRange = lastLine.pop();
            // If the last range is folded, we extend the folded range
            if (lastRange && lastRange.folded) {
                lastRange.to = foldTo;
            }
            // If we popped the last range, add it back
            if (lastRange) {
                lastLine.push(lastRange);
            }
            // If we didn't have a previous range, or the previous range wasn't folded add a new range
            if (!lastRange || !lastRange.folded) {
                lastLine.push({ from: foldFrom, to: foldTo, folded: true });
            }
            // If the line doesn't end in a fold, we add another token for the unfolded section
            if (!lineEndsInFold) {
                lastLine.push({ from: foldTo, to, folded: false });
            }
            lines.push(lastLine);
        }
        else if (lineEndsInFold) {
            lines.push([
                { from, to: foldFrom, folded: false },
                { from: foldFrom, to: foldTo, folded: true },
            ]);
        }
        else {
            lines.push([{ from, to, folded: false }]);
        }
        textOffset = to + 1;
        lineCursor.next();
    }
    return lines;
}
const LinesState = /*@__PURE__*/StateField.define({
    create: (state) => computeLinesState(state),
    update: (current, tr) => {
        if (foldsChanged([tr]) || tr.docChanged) {
            return computeLinesState(tr.state);
        }
        return current;
    },
});
/** Returns if the folds have changed in this update */
function foldsChanged(transactions) {
    return transactions.find((tr) => tr.effects.find((ef) => ef.is(foldEffect) || ef.is(unfoldEffect)));
}

class DiagnosticState extends LineBasedState {
    constructor(view) {
        super(view);
        this.count = undefined;
    }
    shouldUpdate(update) {
        // If the minimap is disabled
        if (!update.state.facet(Config).enabled) {
            return false;
        }
        // If the doc changed
        if (update.docChanged) {
            return true;
        }
        // If the diagnostics changed
        for (const tr of update.transactions) {
            for (const ef of tr.effects) {
                if (ef.is(setDiagnosticsEffect)) {
                    return true;
                }
            }
        }
        // If the folds changed
        if (foldsChanged(update.transactions)) {
            return true;
        }
        // If the minimap was previously hidden
        if (this.count === undefined) {
            return true;
        }
        return false;
    }
    update(update) {
        if (!this.shouldUpdate(update)) {
            return;
        }
        this.map.clear();
        const lines = update.state.field(LinesState);
        this.count = diagnosticCount(update.state);
        forEachDiagnostic(update.state, (diagnostic, from, to) => {
            // Find the start and end lines for the diagnostic
            const lineStart = this.findLine(from, lines);
            const lineEnd = this.findLine(to, lines);
            // Populate each line in the range with the highest severity diagnostic
            let severity = diagnostic.severity;
            for (let i = lineStart; i <= lineEnd; i++) {
                const previous = this.get(i);
                if (previous) {
                    severity = [severity, previous]
                        .sort(this.sort.bind(this))
                        .slice(0, 1)[0];
                }
                this.set(i, severity);
            }
        });
    }
    drawLine(ctx, lineNumber) {
        const { context, lineHeight, offsetX, offsetY } = ctx;
        const severity = this.get(lineNumber);
        if (!severity) {
            return;
        }
        // Draw the full line width rectangle in the background
        context.globalAlpha = 0.65;
        context.beginPath();
        context.rect(offsetX, offsetY /* TODO Scaling causes anti-aliasing in rectangles */, context.canvas.width - offsetX, lineHeight);
        context.fillStyle = this.color(severity);
        context.fill();
        // Draw diagnostic range rectangle in the foreground
        // TODO: We need to update the state to have specific ranges
        // context.globalAlpha = 1;
        // context.beginPath();
        // context.rect(offsetX, offsetY, textWidth, lineHeight);
        // context.fillStyle = this.color(severity);
        // context.fill();
    }
    /**
     * Given a position and a set of line ranges, return
     * the line number the position falls within
     */
    findLine(pos, lines) {
        const index = lines.findIndex((spans) => {
            const start = spans.slice(0, 1)[0];
            const end = spans.slice(-1)[0];
            if (!start || !end) {
                return false;
            }
            return start.from <= pos && pos <= end.to;
        });
        // Line numbers begin at 1
        return index + 1;
    }
    /**
     * Colors from @codemirror/lint
     * https://github.com/codemirror/lint/blob/e0671b43c02e72766ad1afe1579b7032fdcdb6c1/src/lint.ts#L597
     */
    color(severity) {
        return severity === "error"
            ? "#d11"
            : severity === "warning"
                ? "orange"
                : "#999";
    }
    /** Sorts severity from most to least severe */
    sort(a, b) {
        return this.score(b) - this.score(a);
    }
    /** Assigns a score to severity, with most severe being the highest */
    score(s) {
        switch (s) {
            case "error": {
                return 3;
            }
            case "warning": {
                return 2;
            }
            default: {
                return 1;
            }
        }
    }
}
function diagnostics(view) {
    return new DiagnosticState(view);
}

class SelectionState extends LineBasedState {
    constructor(view) {
        super(view);
        this.getDrawInfo();
        this._themeClasses = view.dom.classList.value;
    }
    shouldUpdate(update) {
        // If the minimap is disabled
        if (!update.state.facet(Config).enabled) {
            return false;
        }
        // If the doc changed
        if (update.docChanged) {
            return true;
        }
        // If the selection changed
        if (update.selectionSet) {
            return true;
        }
        // If the theme changed
        if (this._themeClasses !== this.view.dom.classList.value) {
            return true;
        }
        // If the folds changed
        if (foldsChanged(update.transactions)) {
            return true;
        }
        return false;
    }
    update(update) {
        if (!this.shouldUpdate(update)) {
            return;
        }
        this.map.clear();
        /* If class list has changed, clear and recalculate the selection style */
        if (this._themeClasses !== this.view.dom.classList.value) {
            this._drawInfo = undefined;
            this._themeClasses = this.view.dom.classList.value;
        }
        const { ranges } = update.state.selection;
        let selectionIndex = 0;
        for (const [index, line] of update.state.field(LinesState).entries()) {
            const selections = [];
            let offset = 0;
            for (const span of line) {
                do {
                    // We've already processed all selections
                    if (selectionIndex >= ranges.length) {
                        continue;
                    }
                    // The next selection begins after this span
                    if (span.to < ranges[selectionIndex].from) {
                        continue;
                    }
                    // Ignore 0-length selections
                    if (ranges[selectionIndex].from === ranges[selectionIndex].to) {
                        selectionIndex++;
                        continue;
                    }
                    // Build the selection for the current span
                    const range = ranges[selectionIndex];
                    const selection = {
                        from: offset + Math.max(span.from, range.from) - span.from,
                        to: offset + Math.min(span.to, range.to) - span.from,
                        extends: range.to > span.to,
                    };
                    const lastSelection = selections.slice(-1)[0];
                    if (lastSelection && lastSelection.to === selection.from) {
                        // The selection in this span may just be a continuation of the
                        // selection in the previous span
                        // Adjust `to` depending on if we're in a folded span
                        let { to } = selection;
                        if (span.folded && selection.extends) {
                            to = selection.from + 1;
                        }
                        else if (span.folded && !selection.extends) {
                            to = lastSelection.to;
                        }
                        selections[selections.length - 1] = Object.assign(Object.assign({}, lastSelection), { to, extends: selection.extends });
                    }
                    else if (!span.folded) {
                        // It's a new selection; if we're not in a folded span we
                        // should push it onto the stack
                        selections.push(selection);
                    }
                    // If the selection doesn't end in this span, break out of the loop
                    if (selection.extends) {
                        break;
                    }
                    // Otherwise, move to the next selection
                    selectionIndex++;
                } while (selectionIndex < ranges.length &&
                    span.to >= ranges[selectionIndex].from);
                offset += span.folded ? 1 : span.to - span.from;
            }
            // If we don't have any selections on this line, we don't need to store anything
            if (selections.length === 0) {
                continue;
            }
            // Lines are indexed beginning at 1 instead of 0
            const lineNumber = index + 1;
            this.map.set(lineNumber, selections);
        }
    }
    drawLine(ctx, lineNumber) {
        let { context, lineHeight, charWidth, offsetX: startOffsetX, offsetY, } = ctx;
        const selections = this.get(lineNumber);
        if (!selections) {
            return;
        }
        for (const selection of selections) {
            const offsetX = startOffsetX + selection.from * charWidth;
            const textWidth = (selection.to - selection.from) * charWidth;
            const fullWidth = context.canvas.width - offsetX;
            if (selection.extends) {
                // Draw the full width rectangle in the background
                context.globalAlpha = 0.65;
                context.beginPath();
                context.rect(offsetX, offsetY, fullWidth, lineHeight);
                context.fillStyle = this.getDrawInfo().backgroundColor;
                context.fill();
            }
            // Draw text selection rectangle in the foreground
            context.globalAlpha = 1;
            context.beginPath();
            context.rect(offsetX, offsetY, textWidth, lineHeight);
            context.fillStyle = this.getDrawInfo().backgroundColor;
            context.fill();
        }
    }
    getDrawInfo() {
        if (this._drawInfo) {
            return this._drawInfo;
        }
        // Create a mock selection
        const mockToken = document.createElement("span");
        mockToken.setAttribute("class", "cm-selectionBackground");
        this.view.dom.appendChild(mockToken);
        // Get style information
        const style = window.getComputedStyle(mockToken);
        const result = { backgroundColor: style.backgroundColor };
        // Store the result for the next update
        this._drawInfo = result;
        this.view.dom.removeChild(mockToken);
        return result;
    }
}
function selections(view) {
    return new SelectionState(view);
}

class TextState extends LineBasedState {
    constructor(view) {
        super(view);
        this._fontInfoMap = new Map();
        this._themeClasses = new Set(view.dom.classList.values());
        if (view.state.facet(Config).enabled) {
            this.updateImpl(view.state);
        }
    }
    shouldUpdate(update) {
        // If the doc changed
        if (update.docChanged) {
            return true;
        }
        // If configuration settings changed
        if (update.state.facet(Config) !== update.startState.facet(Config)) {
            return true;
        }
        // If the theme changed
        if (this.themeChanged()) {
            return true;
        }
        // If the folds changed
        if (foldsChanged(update.transactions)) {
            return true;
        }
        return false;
    }
    update(update) {
        if (!this.shouldUpdate(update)) {
            return;
        }
        if (this._highlightingCallbackId) {
            typeof window.requestIdleCallback !== "undefined"
                ? cancelIdleCallback(this._highlightingCallbackId)
                : clearTimeout(this._highlightingCallbackId);
        }
        this.updateImpl(update.state, update.changes);
    }
    updateImpl(state, changes) {
        var _a;
        this.map.clear();
        /* Store display text setting for rendering */
        this._displayText = state.facet(Config).displayText;
        /* If class list has changed, clear and recalculate the font info map */
        if (this.themeChanged()) {
            this._fontInfoMap.clear();
        }
        /* Incrementally parse the tree based on previous tree + changes */
        let treeFragments = undefined;
        if (this._previousTree && changes) {
            const previousFragments = TreeFragment.addTree(this._previousTree);
            const changedRanges = [];
            changes.iterChangedRanges((fromA, toA, fromB, toB) => changedRanges.push({ fromA, toA, fromB, toB }));
            treeFragments = TreeFragment.applyChanges(previousFragments, changedRanges);
        }
        /* Parse the document into a lezer tree */
        const docToString = state.doc.toString();
        const parser = (_a = state.facet(language)) === null || _a === void 0 ? void 0 : _a.parser;
        const tree = parser ? parser.parse(docToString, treeFragments) : undefined;
        this._previousTree = tree;
        /* Highlight the document, and store the text and tags for each line */
        const highlighter = {
            style: (tags) => highlightingFor(state, tags),
        };
        let highlights = [];
        if (tree) {
            /**
             * The viewport renders a few extra lines above and below the editor view. To approximate
             * the lines visible in the minimap, we multiply the lines in the viewport by the scale multipliers.
             *
             * Based on the current scroll position, the minimap may show a larger portion of lines above or
             * below the lines currently in the editor view. On a long document, when the scroll position is
             * near the top of the document, the minimap will show a small number of lines above the lines
             * in the editor view, and a large number of lines below the lines in the editor view.
             *
             * To approximate this ratio, we can use the viewport scroll percentage
             *
             * ┌─────────────────────┐
             * │                     │
             * │   Extra viewport    │
             * │   buffer            │
             * ├─────────────────────┼───────┐
             * │                     │Minimap│
             * │                     │Gutter │
             * │                     ├───────┤
             * │    Editor View      │Scaled │
             * │                     │View   │
             * │                     │Overlay│
             * │                     ├───────┤
             * │                     │       │
             * │                     │       │
             * ├─────────────────────┼───────┘
             * │                     │
             * │    Extra viewport   │
             * │    buffer           │
             * └─────────────────────┘
             *
             **/
            const vpLineTop = state.doc.lineAt(this.view.viewport.from).number;
            const vpLineBottom = state.doc.lineAt(this.view.viewport.to).number;
            const vpLineCount = vpLineBottom - vpLineTop;
            const vpScroll = vpLineTop / (state.doc.lines - vpLineCount);
            const { SizeRatio, PixelMultiplier } = Scale;
            const mmLineCount = vpLineCount * SizeRatio * PixelMultiplier;
            const mmLineRatio = vpScroll * mmLineCount;
            const mmLineTop = Math.max(1, Math.floor(vpLineTop - mmLineRatio));
            const mmLineBottom = Math.min(vpLineBottom + Math.floor(mmLineCount - mmLineRatio), state.doc.lines);
            // Highlight the in-view lines synchronously
            highlightTree(tree, highlighter, (from, to, tags) => {
                highlights.push({ from, to, tags });
            }, state.doc.line(mmLineTop).from, state.doc.line(mmLineBottom).to);
        }
        // Update the map
        this.updateMapImpl(state, highlights);
        // Highlight the entire tree in an idle callback
        highlights = [];
        const highlightingCallback = () => {
            if (tree) {
                highlightTree(tree, highlighter, (from, to, tags) => {
                    highlights.push({ from, to, tags });
                });
                this.updateMapImpl(state, highlights);
                this._highlightingCallbackId = undefined;
            }
        };
        this._highlightingCallbackId =
            typeof window.requestIdleCallback !== "undefined"
                ? requestIdleCallback(highlightingCallback)
                : setTimeout(highlightingCallback);
    }
    updateMapImpl(state, highlights) {
        this.map.clear();
        const docToString = state.doc.toString();
        const highlightsIterator = highlights.values();
        let highlightPtr = highlightsIterator.next();
        for (const [index, line] of state.field(LinesState).entries()) {
            const spans = [];
            for (const span of line) {
                // Skip if it's a 0-length span
                if (span.from === span.to) {
                    continue;
                }
                // Append a placeholder for a folded span
                if (span.folded) {
                    spans.push({ text: "…", tags: "" });
                    continue;
                }
                let position = span.from;
                while (!highlightPtr.done && highlightPtr.value.from < span.to) {
                    const { from, to, tags } = highlightPtr.value;
                    // Iterate until our highlight is over the current span
                    if (to < position) {
                        highlightPtr = highlightsIterator.next();
                        continue;
                    }
                    // Append unstyled text before the highlight begins
                    if (from > position) {
                        spans.push({ text: docToString.slice(position, from), tags: "" });
                    }
                    // A highlight may start before and extend beyond the current span
                    const start = Math.max(from, span.from);
                    const end = Math.min(to, span.to);
                    // Append the highlighted text
                    spans.push({ text: docToString.slice(start, end), tags });
                    position = end;
                    // If the highlight continues beyond this span, break from this loop
                    if (to > end) {
                        break;
                    }
                    // Otherwise, move to the next highlight
                    highlightPtr = highlightsIterator.next();
                }
                // If there are remaining spans that did not get highlighted, append them unstyled
                if (position !== span.to) {
                    spans.push({
                        text: docToString.slice(position, span.to),
                        tags: "",
                    });
                }
            }
            // Lines are indexed beginning at 1 instead of 0
            const lineNumber = index + 1;
            this.map.set(lineNumber, spans);
        }
    }
    measure(context) {
        const { color, font, lineHeight } = this.getFontInfo("");
        context.textBaseline = "ideographic";
        context.fillStyle = color;
        context.font = font;
        return {
            charWidth: context.measureText("_").width,
            lineHeight: lineHeight,
        };
    }
    beforeDraw() {
        this._fontInfoMap.clear(); // TODO: Confirm this worked for theme changes or get rid of it because it's slow
    }
    drawLine(ctx, lineNumber) {
        const line = this.get(lineNumber);
        if (!line) {
            return;
        }
        let { context, charWidth, lineHeight, offsetX, offsetY } = ctx;
        let prevInfo;
        context.textBaseline = "ideographic";
        for (const span of line) {
            const info = this.getFontInfo(span.tags);
            if (!prevInfo || prevInfo.color !== info.color) {
                context.fillStyle = info.color;
            }
            if (!prevInfo || prevInfo.font !== info.font) {
                context.font = info.font;
            }
            prevInfo = info;
            lineHeight = Math.max(lineHeight, info.lineHeight);
            switch (this._displayText) {
                case "characters": {
                    // TODO: `fillText` takes up the majority of profiling time in `render`
                    // Try speeding it up with `drawImage`
                    // https://stackoverflow.com/questions/8237030/html5-canvas-faster-filltext-vs-drawimage/8237081
                    context.fillText(span.text, offsetX, offsetY + lineHeight);
                    offsetX += span.text.length * charWidth;
                    break;
                }
                case "blocks": {
                    const nonWhitespace = /\S+/g;
                    let start;
                    while ((start = nonWhitespace.exec(span.text)) !== null) {
                        const startX = offsetX + start.index * charWidth;
                        let width = (nonWhitespace.lastIndex - start.index) * charWidth;
                        // Reached the edge of the minimap
                        if (startX > context.canvas.width) {
                            break;
                        }
                        // Limit width to edge of minimap
                        if (startX + width > context.canvas.width) {
                            width = context.canvas.width - startX;
                        }
                        // Scaled 2px buffer between lines
                        const yBuffer = 2 / Scale.SizeRatio;
                        const height = lineHeight - yBuffer;
                        context.fillStyle = info.color;
                        context.globalAlpha = 0.65; // Make the blocks a bit faded
                        context.beginPath();
                        context.rect(startX, offsetY, width, height);
                        context.fill();
                    }
                    offsetX += span.text.length * charWidth;
                    break;
                }
            }
        }
    }
    getFontInfo(tags) {
        const cached = this._fontInfoMap.get(tags);
        if (cached) {
            return cached;
        }
        // Create a mock token wrapped in a cm-line
        const mockToken = crelt("span", { class: tags });
        const mockLine = crelt("div", { class: "cm-line", style: "display: none" }, mockToken);
        this.view.contentDOM.appendChild(mockLine);
        // Get style information and store it
        const style = window.getComputedStyle(mockToken);
        const lineHeight = parseFloat(style.lineHeight) / Scale.SizeRatio;
        const result = {
            color: style.color,
            font: `${style.fontStyle} ${style.fontWeight} ${lineHeight}px ${style.fontFamily}`,
            lineHeight,
        };
        this._fontInfoMap.set(tags, result);
        // Clean up and return
        this.view.contentDOM.removeChild(mockLine);
        return result;
    }
    themeChanged() {
        const previous = this._themeClasses;
        const now = new Set(this.view.dom.classList.values());
        this._themeClasses = now;
        if (!previous) {
            return true;
        }
        // Ignore certain classes being added/removed
        previous.delete("cm-focused");
        now.delete("cm-focused");
        if (previous.size !== now.size) {
            return true;
        }
        let containsAll = true;
        previous.forEach((theme) => {
            if (!now.has(theme)) {
                containsAll = false;
            }
        });
        return !containsAll;
    }
}
function text(view) {
    return new TextState(view);
}

const GUTTER_WIDTH = 4;
/**
 * Draws a gutter to the canvas context for the given line number
 */
function drawLineGutter(gutter, ctx, lineNumber) {
    const color = gutter[lineNumber];
    if (!color) {
        return;
    }
    ctx.context.fillStyle = color;
    ctx.context.globalAlpha = 1;
    ctx.context.beginPath();
    ctx.context.rect(ctx.offsetX, ctx.offsetY, GUTTER_WIDTH, ctx.lineHeight);
    ctx.context.fill();
}

const Theme = /*@__PURE__*/EditorView.theme({
    "&": {
        height: "100%",
        overflowY: "auto",
    },
    "& .cm-minimap-gutter": {
        borderRight: 0,
        flexShrink: 0,
        left: "unset",
        position: "sticky",
        right: 0,
        top: 0,
    },
    "& .cm-minimap-inner": {
        height: "100%",
        position: "absolute",
        right: 0,
        top: 0,
        overflowY: "hidden",
        "& canvas": {
            display: "block",
        },
    },
    "& .cm-minimap-box-shadow": {
        boxShadow: "12px 0px 20px 5px #6c6c6c",
    },
});
const WIDTH_RATIO = 6;
const minimapClass = /*@__PURE__*/ViewPlugin.fromClass(class {
    constructor(view) {
        this.view = view;
        this.text = text(view);
        this.selection = selections(view);
        this.diagnostic = diagnostics(view);
        if (view.state.facet(showMinimap)) {
            this.create(view);
        }
    }
    create(view) {
        const config = view.state.facet(showMinimap);
        if (!config) {
            throw Error("Expected nonnull minimap config");
        }
        this.inner = crelt("div", { class: "cm-minimap-inner" });
        this.canvas = crelt("canvas");
        // 直接创建 gutter 元素
        this.dom = crelt("div", { class: "cm-gutters cm-minimap-gutter" });
        this.dom.appendChild(this.inner);
        this.inner.appendChild(this.canvas);
        // 插入到编辑器
        this.view.scrollDOM.insertBefore(this.dom, this.view.contentDOM.nextSibling);
        // 设置事件监听
        const eventHandlers = this.view.state.facet(Config).eventHandlers;
        for (const key in eventHandlers) {
            const handler = eventHandlers[key];
            if (handler) {
                this.dom.addEventListener(key, (e) => handler(e, this.view));
            }
        }
    }

    remove() {
        if (this.dom) {
            this.dom.remove();
        }
    }
    update(update) {
        const prev = update.startState.facet(showMinimap);
        const now = update.state.facet(showMinimap);
        if (prev && !now) {
            this.remove();
            return;
        }
        if (!prev && now) {
            this.create(update.view);
        }
        if (now) {
            this.text.update(update);
            this.selection.update(update);
            this.diagnostic.update(update);
            this.render();
        }
    }
    getWidth() {
        const editorWidth = this.view.dom.clientWidth;
        if (editorWidth <= Scale.MaxWidth * WIDTH_RATIO) {
            const ratio = editorWidth / (Scale.MaxWidth * WIDTH_RATIO);
            return Scale.MaxWidth * ratio;
        }
        return Scale.MaxWidth;
    }
    render() {
        // If we don't have elements to draw to exit early
        if (!this.dom || !this.canvas || !this.inner) {
            return;
        }
        this.text.beforeDraw();
        this.updateBoxShadow();
        this.dom.style.width = this.getWidth() + "px";
        this.canvas.style.maxWidth = this.getWidth() + "px";
        this.canvas.width = this.getWidth() * Scale.PixelMultiplier;
        const domHeight = this.view.dom.getBoundingClientRect().height;
        this.inner.style.minHeight = domHeight + "px";
        this.canvas.height = domHeight * Scale.PixelMultiplier;
        this.canvas.style.height = domHeight + "px";
        const context = this.canvas.getContext("2d");
        if (!context) {
            return;
        }
        context.clearRect(0, 0, this.canvas.width, this.canvas.height);
        /* We need to get the correct font dimensions before this to measure characters */
        const { charWidth, lineHeight } = this.text.measure(context);
        let { startIndex, endIndex, offsetY } = this.canvasStartAndEndIndex(context, lineHeight);
        const gutters = this.view.state.facet(Config).gutters;
        for (let i = startIndex; i < endIndex; i++) {
            const lines = this.view.state.field(LinesState);
            if (i >= lines.length)
                break;
            const drawContext = {
                offsetX: 0,
                offsetY,
                context,
                lineHeight,
                charWidth,
            };
            if (gutters.length) {
                /* Small leading buffer */
                drawContext.offsetX += 2;
                for (let gutter of gutters) {
                    drawLineGutter(gutter, drawContext, i + 1);
                    drawContext.offsetX += GUTTER_WIDTH;
                }
                /* Small trailing buffer */
                drawContext.offsetX += 2;
            }
            this.text.drawLine(drawContext, i + 1);
            this.selection.drawLine(drawContext, i + 1);
            this.diagnostic.drawLine(drawContext, i + 1);
            offsetY += lineHeight;
        }
        context.restore();
    }
    canvasStartAndEndIndex(context, lineHeight) {
        let { top: pTop, bottom: pBottom } = this.view.documentPadding;
        (pTop /= Scale.SizeRatio), (pBottom /= Scale.SizeRatio);
        const canvasHeight = context.canvas.height;
        const { clientHeight, scrollHeight, scrollTop } = this.view.scrollDOM;
        let scrollPercent = scrollTop / (scrollHeight - clientHeight);
        if (isNaN(scrollPercent)) {
            scrollPercent = 0;
        }
        const lineCount = this.view.state.field(LinesState).length;
        const totalHeight = pTop + pBottom + lineCount * lineHeight;
        const canvasTop = Math.max(0, scrollPercent * (totalHeight - canvasHeight));
        const offsetY = Math.max(0, pTop - canvasTop);
        const startIndex = Math.round(Math.max(0, canvasTop - pTop) / lineHeight);
        const spaceForLines = Math.round((canvasHeight - offsetY) / lineHeight);
        return {
            startIndex,
            endIndex: startIndex + spaceForLines,
            offsetY,
        };
    }
    updateBoxShadow() {
        if (!this.canvas) {
            return;
        }
        const { clientWidth, scrollWidth, scrollLeft } = this.view.scrollDOM;
        if (clientWidth + scrollLeft < scrollWidth) {
            this.canvas.classList.add("cm-minimap-box-shadow");
        }
        else {
            this.canvas.classList.remove("cm-minimap-box-shadow");
        }
    }
    destroy() {
        this.remove();
    }
}, {
    eventHandlers: {
        scroll() {
            requestAnimationFrame(() => this.render());
        },
    },
    provide: (plugin) => {
        return EditorView.scrollMargins.of((view) => {
            var _a;
            const width = (_a = view.plugin(plugin)) === null || _a === void 0 ? void 0 : _a.getWidth();
            if (!width) {
                return null;
            }
            return { right: width };
        });
    },
});
/**
 * Facet used to show a minimap in the right gutter of the editor using the
 * provided configuration.
 *
 * If you return `null`, a minimap will not be shown.
 */
const showMinimap = /*@__PURE__*/Facet.define({
    combine: (c) => { var _a; return (_a = c.find((o) => o !== null)) !== null && _a !== void 0 ? _a : null; },
    enables: (f) => {
        return [
            [
                Config.compute([f], (s) => s.facet(f)),
                Theme,
                LinesState,
                minimapClass,
                Overlay,
            ],
        ];
    },
});

export { showMinimap };
