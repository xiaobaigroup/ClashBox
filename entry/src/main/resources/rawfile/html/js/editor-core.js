/**
 * 鸿蒙代码编辑器 - Web端核心逻辑
 */
class HarmonyCodeEditor {
    constructor() {
        this.editor = null;
        this.minimap = null;
        this.themeCompartment = null;
        this.communicationPort = null;
        this.isInitialized = false;
        this.hasReceivedConfig = false;
        this.initializationInProgress = false;
        this.currentTheme = 'light'; // 添加当前主题跟踪
        this.pendingConfig = null; // 等待处理的配置

        // 主题缓存
        this.themeCache = {
            light: null,
            dark: null
        };
        // 模块缓存
        this.cachedModules = null;

        this.setupCommunication();
    }

    async init() {
        try {
            await this.setupCommunication();
            // 发送ready事件（携带状态信息）
            this.sendEvent('ready', {
                status: 'success',
                theme: this.currentTheme || 'light'
            });
            console.log('Editor initialization completed');
        } catch (error) {
            console.error('Failed to initialize editor:', error);
            this.sendEvent('ready', {
                status: 'error',
                message: error.message
            });
            this.showError('Failed to initialize editor: ' + error.message);
        }
    }

    /**
     * 初始化基础编辑器（不依赖配置）
     */
    async initializeEditor() {
        try {
            this.updateLoadingStatus('Loading editor modules...');

            // 加载模块
            const modules = await this.loadCodeMirrorModules();

            // 创建基础编辑器（使用默认配置）
            this.createEditor(modules, {
                theme: 'light',
                language: 'javascript',
                content: '// Initializing...',
                minimap: false
            });

            this.isInitialized = true;
            console.log('Base editor initialized successfully');
        } catch (error) {
            console.error('Failed to initialize base editor:', error);
            throw error;
        }
    }

    /**
     * 设置通信
     */
    setupCommunication() {
        // 立即监听端口消息
        window.addEventListener('message', (event) => {
            if (event.data === 'initEditorPort' && event.ports?.length > 0) {
                this.communicationPort = event.ports[0];
                this.communicationPort.onmessage = (e) => {
                    this.handleNativeMessage(e.data);
                };
                console.log('Communication port established successfully');

                // 如果有等待处理的配置，立即应用
                if (this.pendingConfig) {
                    console.log('Applying pending config after port establishment');
                    this.applyConfig(this.pendingConfig);
                    this.pendingConfig = null;
                }

                // 发送ready事件
                this.sendEvent('ready', {
                    status: 'success',
                    theme: this.currentTheme
                });
                console.log('Ready event sent to ArkTS');
            }
        });
    }

    /**
     * 处理原生端消息
     */
    handleNativeMessage(message) {
        try {
            const data = typeof message === 'string' ? JSON.parse(message) : message;
            console.log('Received message from ArkTS:', data);

            switch (data.type) {
                case 'command':
                    this.handleCommand(data);
                    break;
                case 'event':
                    this.handleEvent(data);
                    break;
                default:
                    console.warn('Unknown message type:', data.type);
            }
        } catch (error) {
            console.error('Failed to handle native message:', error);
        }
    }

    /**
     * 处理命令
     */
    async handleCommand(message) {
        const { id, command, data } = message;

        try {
            let result;

            switch (command) {
                case 'setContent':
                    result = await this.setContent(data.content);
                    break;
                case 'getContent':
                    result = await this.getContent();
                    break;
                case 'setTheme':
                    result = await this.setTheme(data.theme);
                    break;
                case 'setLanguage':
                    result = await this.setLanguage(data.language);
                    break;
                case 'insertText':
                    result = await this.insertText(data.text);
                    break;
                case 'getSelection':
                    result = await this.getSelection();
                    break;
                case 'focus':
                    result = await this.focus();
                    break;
                case 'execute':
                    result = await this.executeCommand(data.command);
                    break;
                case 'setWordWrap':
                    result = await this.setWordWrap(data.enabled);
                    break;
                default:
                    throw new Error(`Unknown command: ${command}`);
            }

            this.sendResponse(id, result);
        } catch (error) {
            this.sendResponse(id, null, error.message);
        }
    }

    /**
     * 处理事件
     */
    async handleEvent(message) {
        const { event, data } = message;
        console.log('Processing event:', event, data);

        switch (event) {
            case 'config':
                console.log('Received config event');
                // 如果通信端口尚未建立，保存配置等待端口就绪
                if (!this.communicationPort) {
                    console.log('Communication port not ready, storing config for later');
                    this.pendingConfig = data;
                } else {
                    await this.applyConfig(data);
                }
                break;
            case 'test':
                console.log('Test event received:', data);
                break;
            default:
                console.warn('Unknown event type:', event);
        }
    }

    /**
     * 应用配置
     */
    async applyConfig(config) {
        // 如果正在初始化中，检查是否是相同的配置
        if (this.initializationInProgress) {
            if (this.isSameConfig(config)) {
                console.log('Same config received during initialization, skipping');
                return;
            } else {
                console.log('Different config received during initialization, will apply after current initialization');
                // 延迟应用新配置
                setTimeout(() => {
                    this.applyConfig(config);
                }, 100);
                return;
            }
        }

        // 如果已经初始化并且配置相同，跳过
        if (this.isInitialized && this.isSameConfig(config)) {
            console.log('Same config received, skipping reinitialization');
            return;
        }

        console.log('Applying configuration:', config);

        if (!config) {
            console.error('No config provided');
            this.showError('No configuration received');
            return;
        }

        this.initializationInProgress = true;
        this.hasReceivedConfig = true;

        try {
            // 检查是否只是主题变化（只有在编辑器已初始化时）
            if (this.isInitialized && this.isOnlyThemeChange(config)) {
                console.log('Only theme changed, attempting dynamic switch');
                const success = await this.switchThemeDynamically(config.theme);
                if (success) {
                    console.log('Dynamic theme switch successful');
                    this.initializationInProgress = false;
                    return;
                }
                console.log('Dynamic switch failed, falling back to recreation');
            }

            // 重新创建编辑器
            if (this.editor) {
                console.log('Destroying existing editor before reinitialization');
                this.destroy();
            }

            // 使用缓存的模块创建编辑器
            const modules = this.cachedModules || await this.loadCodeMirrorModules();
            this.createEditor(modules, config);
            this.isInitialized = true;

            console.log('Editor reconfigured successfully');

            // 发送配置应用完成事件
            this.sendEvent('configApplied', {
                theme: config.theme,
                language: config.language
            });

        } catch (error) {
            console.error('Failed to apply config:', error);
            this.showError(`Configuration failed: ${error.message}`);
            this.sendEvent('error', error.message);
        } finally {
            this.initializationInProgress = false;
        }
    }

    /**
     * 检查配置是否相同
     */
    isSameConfig(newConfig) {
        if (!this.lastConfig) return false;

        return (
            this.lastConfig.theme === newConfig.theme &&
                this.lastConfig.language === newConfig.language &&
                this.lastConfig.fontSize === newConfig.fontSize &&
                this.lastConfig.tabSize === newConfig.tabSize &&
                this.lastConfig.content === newConfig.content &&
                this.lastConfig.minimap === newConfig.minimap
        );
    }

    async loadCodeMirrorModules() {
        console.log('Starting to load CodeMirror modules...');

        // 如果模块已缓存，直接返回
        if (this.cachedModules) {
            console.log('Using cached modules');
            return this.cachedModules;
        }

        try {
            const moduleImports = await Promise.all([
                import('@codemirror/state').catch(err => {
                    console.error('Failed to load @codemirror/state:', err);
                    throw new Error('CodeMirror state module load failed');
                }),
                import('@codemirror/view').catch(err => {
                    console.error('Failed to load @codemirror/view:', err);
                    throw new Error('CodeMirror view module load failed');
                }),
                import('@codemirror/commands').catch(err => {
                    console.error('Failed to load @codemirror/commands:', err);
                    throw new Error('CodeMirror commands module load failed');
                }),
                import('@codemirror/language').catch(err => {
                    console.error('Failed to load @codemirror/language:', err);
                    throw new Error('CodeMirror language module load failed');
                }),
                import('@codemirror/autocomplete').catch(err => {
                    console.error('Failed to load @codemirror/autocomplete:', err);
                    throw new Error('CodeMirror autocomplete module load failed');
                }),
                import('@codemirror/search').catch(err => {
                    console.error('Failed to load @codemirror/search:', err);
                    throw new Error('CodeMirror search module load failed');
                }),
                import('@codemirror/lang-javascript').catch(err => {
                    console.error('Failed to load @codemirror/lang-javascript:', err);
                    throw new Error('JavaScript language module load failed');
                }),
                // 分别加载主题并缓存
                import('@codemirror/theme-one-dark').catch(err => {
                    console.error('Failed to load @codemirror/theme-one-dark:', err);
                    return { oneDark: null }; // 失败时返回null
                }),
                // minimap导入
                this.loadMinimapModule().catch(err => {
                    console.warn('Failed to load minimap, continuing without it:', err);
                    return { showMinimap: null };
                })
            ]);

            console.log('All CodeMirror modules loaded successfully');

            const [
                { EditorState },
                viewModule, // 修改：不直接解构，先保存整个模块
                { defaultKeymap, history, historyKeymap },
                { foldGutter, bracketMatching },
                { closeBrackets, autocompletion },
                { searchKeymap },
                { javascript },
                { oneDark },  // 解构主题
                minimapModule
            ] = moduleImports;

            // 安全获取 ViewPlugin 和其他 view 模块导出
            const { EditorView, keymap, drawSelection, lineNumbers, highlightActiveLine } = viewModule;
            const ViewPlugin = viewModule.ViewPlugin || viewModule.default?.ViewPlugin;

            if (!ViewPlugin) {
                throw new Error('ViewPlugin not found in view module');
            }

            // 获取 Compartment
            console.log('=== COMPARTMENT DEBUG ===');
            console.log('EditorView type:', typeof EditorView);
            console.log('EditorView keys:', Object.keys(EditorView));
            console.log('EditorView.Compartment:', EditorView.Compartment);

            // 检查 Compartment 的可用性
            let Compartment;
            if (EditorView.Compartment) {
                Compartment = EditorView.Compartment;
                console.log('Compartment found in EditorView.Compartment');
            } else if (typeof Compartment === 'function') {
                console.log('Compartment already available');
            } else {
                console.error('Compartment not found, falling back to simple theme switching');
                // 如果 Compartment 不可用，我们将使用简单的重建方案
                Compartment = null;
            }

            // 创建主题 Compartment（如果可用）
            if (Compartment) {
                this.themeCompartment = new Compartment();
                console.log('Theme compartment created successfully');
            } else {
                this.themeCompartment = null;
                console.log('Theme compartment disabled');
            }

            // 缓存主题
            this.themeCache = {
                light: null, // 浅色主题使用默认
                dark: oneDark
            };

            // 缓存所有模块
            this.cachedModules = {
                EditorState,
                EditorView,
                keymap,
                ViewPlugin, // 显式缓存 ViewPlugin
                drawSelection,
                lineNumbers,
                highlightActiveLine,
                defaultKeymap,
                history,
                historyKeymap,
                foldGutter,
                bracketMatching,
                closeBrackets,
                autocompletion,
                searchKeymap,
                javascript,
                oneDark,
                showMinimap: minimapModule?.showMinimap || null,
                Compartment // 缓存 Compartment（可能为 null）
            };

            return this.cachedModules;

        } catch (error) {
            console.error('Critical module loading failed:', error);
            throw new Error(`Module loading failed: ${error.message}`);
        }
    }

    /**
     * 创建一个用于实时监听内容变化的 ViewPlugin
     * @param {ViewPlugin} ViewPlugin - ViewPlugin 类
     * @returns {ViewPlugin}
     */
    createContentChangePlugin(ViewPlugin) {
        // 确保类中的 'this' 指向正确
        const self = this;
        return ViewPlugin.fromClass(class {
            update(update) {
                // 只有当文档内容真的发生变化时才触发
                if (update.docChanged) {
                    // 获取最新的文档内容
                    const content = update.state.doc.toString();
                    console.log('Content changed via ViewPlugin, length:', content.length);
                    // 立即通过通信端口发送事件到 ArkTS
                    self.sendEvent('contentChange', content);
                }
            }
        });
    }

    /**
     * 深度调试 minimap 导出
     */
    async loadMinimapModule() {
        try {
            const minimapImport = await import('@replit/codemirror-minimap');

            console.log('=== MINIMAP MODULE DEBUG ===');
            console.log('Minimap module type:', typeof minimapImport);
            console.log('Minimap module keys:', Object.keys(minimapImport));
            console.log('Minimap module full structure:', minimapImport);

            // 检查 Symbol 属性
            if (typeof Symbol !== 'undefined' && Symbol.iterator in minimapImport) {
                console.log('Minimap is iterable');
            }

            // 检查默认导出
            if (minimapImport.default) {
                console.log('Minimap has default export:', minimapImport.default);
                console.log('Default export keys:', Object.keys(minimapImport.default));
            }

            // 尝试各种可能的导出方式
            let showMinimapExport = null;

            // 方式1: 直接导出
            if (minimapImport.showMinimap) {
                console.log('Found showMinimap direct export');
                showMinimapExport = minimapImport.showMinimap;
            }
            // 方式2: 默认导出中包含 showMinimap
            else if (minimapImport.default && minimapImport.default.showMinimap) {
                console.log('Found showMinimap in default export');
                showMinimapExport = minimapImport.default.showMinimap;
            }
            // 方式3: 模块本身就是 showMinimap
            else if (typeof minimapImport === 'function' || (minimapImport && minimapImport.of)) {
                console.log('Module itself might be showMinimap');
                showMinimapExport = minimapImport;
            }

            if (showMinimapExport) {
                console.log('ShowMinimap export type:', typeof showMinimapExport);
                console.log('ShowMinimap export:', showMinimapExport);

                // 检查是否是 Facet
                if (showMinimapExport.of) {
                    console.log('ShowMinimap is a Facet, using .of() method');
                    return {
                        showMinimap: (config) => showMinimapExport.of(config || {}),
                        isFacet: true
                    };
                }
                // 检查是否是函数
                else if (typeof showMinimapExport === 'function') {
                    console.log('ShowMinimap is a function');
                    return {
                        showMinimap: showMinimapExport,
                        isFacet: false
                    };
                }
            }

            console.warn('Minimap export structure not recognized:', minimapImport);
            throw new Error(`Minimap export format not recognized: ${JSON.stringify(minimapImport)}`);

        } catch (error) {
            console.error('Minimap module import failed:', error);
            throw error;
        }
    }

    /**
     * 创建编辑器，处理minimap Facet
     */
    createEditor(modules, config) {
        // 保存最后配置用于比较
        this.lastConfig = { ...config };

        const {
            EditorState,
            EditorView,
            keymap,
            drawSelection,
            lineNumbers,
            highlightActiveLine,
            defaultKeymap,
            history,
            historyKeymap,
            foldGutter,
            bracketMatching,
            closeBrackets,
            autocompletion,
            searchKeymap,
            javascript,
            oneDark,
            showMinimap,
            isFacet,
            Compartment, // 获取 Compartment（可能为 null）
            ViewPlugin, // 确保解构出 ViewPlugin
        } = modules;

        // 清理现有编辑器
        if (this.editor) {
            this.editor.destroy();
        }
        if (this.minimap) {
            this.minimap.destroy();
            this.minimap = null;
        }

        const editorElement = document.getElementById('editor');
        const minimapElement = document.getElementById('minimap');

        // 清除加载状态
        editorElement.innerHTML = '';

        // 设置编辑器容器样式
        this.updateContainerTheme(config.theme);

        try {
            // 传递 ViewPlugin 参数创建插件
            const contentChangePlugin = this.createContentChangePlugin(ViewPlugin);

            // 创建基础扩展
            const extensions = [
                lineNumbers(),
                highlightActiveLine(),
                history(),
                drawSelection(),
                foldGutter(),
                bracketMatching(),
                closeBrackets(),
                autocompletion(),
                keymap.of([...defaultKeymap, ...historyKeymap, ...searchKeymap]),
                EditorState.allowMultipleSelections.of(true),
                contentChangePlugin
            ];

            // 添加语言支持
            if (config.language === 'javascript' && javascript) {
                extensions.push(javascript());
            }

            // 添加自动换行支持
            if (config.wordWrap) {
                extensions.push(EditorView.lineWrapping);
                console.log('Word wrap enabled');
            }

            // 根据 Compartment 可用性选择主题应用方式
            if (this.themeCompartment && Compartment) {
                // 使用 Compartment 管理主题
                const themeExtension = config.theme === 'dark' && oneDark ? oneDark : [];
                extensions.push(this.themeCompartment.of(themeExtension));
                console.log('Theme applied using Compartment:', config.theme);
            } else {
                // 直接应用主题（不使用 Compartment）
                if (config.theme === 'dark' && oneDark) {
                    extensions.push(oneDark);
                    console.log('Theme applied directly:', config.theme);
                } else {
                    console.log('Using default light theme');
                }
            }

            if (showMinimap && config.minimap) {
                if (isFacet) {
                    const minimapConfig = {
                        showOverlay: "always",
                        displayText: "characters"
                    };
                    extensions.push(showMinimap.of(minimapConfig));
                    console.log('Minimap Facet added with config');
                } else if (typeof showMinimap === 'function') {
                    extensions.push(showMinimap());
                    console.log('Minimap function added');
                }
            }

            // 创建编辑器状态
            const initialState = EditorState.create({
                doc: config.content || '// Welcome to Code Editor\nconsole.log("Hello, HarmonyOS!");',
                extensions
            });

            // 创建编辑器视图
            this.editor = new EditorView({
                state: initialState,
                parent: editorElement
            });

            console.log('Editor view created successfully');

            // 设置事件监听
            this.setupEditorEvents();

            console.log('Editor created successfully with config:', config);

        } catch (error) {
            console.error('Failed to create editor:', error);
            editorElement.innerHTML = `
            <div class="loading" style="color: #ff6b6b;">
                Editor creation failed: ${error.message}
            </div>
        `;
            throw error;
        }
    }

    /**
     * 设置编辑器事件
     */
    setupEditorEvents() {
        // 内容变化事件 已由 ViewPlugin 处理
        // this.editor.contentDOM.addEventListener('input', () => {
        //     this.sendEvent('contentChange', this.getContent());
        // });

        // 选择变化事件
        this.editor.contentDOM.addEventListener('selectionchange', () => {
            this.sendEvent('selectionChange', this.getSelection());
        });

        // 焦点事件
        this.editor.contentDOM.addEventListener('focus', () => {
            this.sendEvent('editingChange', true);
        });

        this.editor.contentDOM.addEventListener('blur', () => {
            this.sendEvent('editingChange', false);
        });

        // 键盘事件
        this.editor.contentDOM.addEventListener('keydown', (event) => {
            if ((event.ctrlKey || event.metaKey) && event.key === 's') {
                event.preventDefault();
                this.sendEvent('save');
            }
        });
    }

    /**
     * 编辑器API方法
     */
    setContent(content) {
        if (!this.editor) throw new Error('Editor not initialized');

        this.editor.dispatch({
            changes: {
                from: 0,
                to: this.editor.state.doc.length,
                insert: content
            }
        });
        return true;
    }

    // 设置自动换行
    async setWordWrap(enabled) {
        if (!this.editor) throw new Error('Editor not initialized');
        // 由于 lineWrapping 是静态扩展，需要重新创建编辑器
        const currentContent = this.getContent();
        const currentSelection = this.getSelection();
        // 更新配置
        if (this.lastConfig) {
            this.lastConfig.wordWrap = enabled;
        }
        // 重新创建编辑器
        this.createEditor(this.cachedModules, this.lastConfig);
        // 恢复内容
        setTimeout(() => {
            this.setContent(currentContent);
            if (currentSelection && currentSelection.from !== currentSelection.to) {
                this.editor.dispatch({
                    selection: {
                        anchor: currentSelection.from,
                        head: currentSelection.to
                    }
                });
            }
        }, 50);
        return true;
    }

    getContent() {
        return this.editor ? this.editor.state.doc.toString() : '';
    }

    // 设置主题（保留编辑状态）
    async setTheme(theme) {
        this.switchThemeDynamically(theme);
    }

    /**
     * 动态切换主题
     */
    async switchThemeDynamically(themeName) {
        console.log('=== THEME SWITCH DEBUG ===');
        console.log('Target theme:', themeName);
        console.log('Editor exists:', !!this.editor);
        console.log('Modules cached:', !!this.cachedModules);
        console.log('Theme compartment exists:', !!this.themeCompartment);
        console.log('Theme cache:', this.themeCache);

        if (!this.editor || !this.cachedModules) {
            console.error('Required components not ready for theme switch');
            return false;
        }

        // 根据 Compartment 可用性选择切换方式
        if (this.themeCompartment) {
            // 使用 Compartment 动态切换
            const themeExtension = this.themeCache[themeName];
            console.log('Theme extension:', themeExtension);

            try {
                console.log('Attempting to reconfigure theme compartment...');

                this.editor.dispatch({
                    effects: this.themeCompartment.reconfigure(themeExtension ? [themeExtension] : [])
                });

                console.log('Theme compartment reconfigured successfully');

                this.updateContainerTheme(themeName);

                if (this.lastConfig) {
                    this.lastConfig.theme = themeName;
                }

                // 更新当前主题跟踪
                this.currentTheme = themeName;

                console.log(`Theme switched to ${themeName} successfully using Compartment`);
                return true;

            } catch (error) {
                console.error('Failed to switch theme using Compartment:', error);
                console.log('Falling back to optimized recreation...');
                // 继续执行下面的重建方案
            }
        }

        // 备选方案：重建（保持状态）
        console.log('Using optimized recreation for theme switch');
        try {
            // 保存当前状态
            const currentContent = this.getContent();
            const currentSelection = this.getSelection();
            const scrollTop = this.editor.scrollDOM.scrollTop;
            const cursorPos = this.editor.state.selection.main.head;

            // 销毁当前编辑器
            this.editor.destroy();

            // 创建新配置
            const newConfig = { ...this.lastConfig, theme: themeName };

            // 快速重建（使用缓存的模块）
            this.createEditor(this.cachedModules, newConfig);

            // 恢复状态
            setTimeout(() => {
                if (this.editor) {
                    // 恢复内容
                    if (currentContent !== this.getContent()) {
                        this.setContent(currentContent);
                    }

                    // 恢复光标位置
                    this.editor.dispatch({
                        selection: { anchor: cursorPos, head: cursorPos }
                    });

                    // 恢复选区
                    if (currentSelection && currentSelection.from !== currentSelection.to) {
                        this.editor.dispatch({
                            selection: {
                                anchor: currentSelection.from,
                                head: currentSelection.to
                            }
                        });
                    }

                    // 恢复滚动位置
                    this.editor.scrollDOM.scrollTop = scrollTop;
                }
            }, 50);

            // 更新配置
            this.lastConfig = newConfig;

            // 更新当前主题跟踪
            this.currentTheme = themeName;

            console.log(`Theme switched to ${themeName} successfully with optimized recreation`);
            return true;

        } catch (error) {
            console.error('Failed to switch theme with optimized recreation:', error);
            return false;
        }
    }

    /**
     * 更新编辑器容器样式
     */
    updateContainerTheme(themeName) {
        const editorElement = document.getElementById('editor');
        if (!editorElement) return;

        if (themeName === 'dark') {
            editorElement.style.background = '#1e1e1e';
            editorElement.style.color = '#ffffff';
        } else {
            editorElement.style.background = '#ffffff';
            editorElement.style.color = '#000000';
        }
    }

    /**
     * 检查是否只是主题变化
     */
    isOnlyThemeChange(newConfig) {
        if (!this.lastConfig || !this.isInitialized) {
            return false;
        }
        // 检查除了主题外，其他配置是否相同
        const otherConfigsSame = (
            this.lastConfig.language === newConfig.language &&
                this.lastConfig.fontSize === newConfig.fontSize &&
                this.lastConfig.tabSize === newConfig.tabSize &&
                this.lastConfig.content === newConfig.content &&
                this.lastConfig.minimap === newConfig.minimap
        );
        // 检查主题是否确实变化了
        const themeChanged = this.lastConfig.theme !== newConfig.theme;

        return otherConfigsSame && themeChanged;
    }

    setLanguage(language) {
        console.log('Setting language to:', language);
        // 语言切换逻辑需要重新创建编辑器
        return true;
    }

    insertText(text) {
        if (!this.editor) throw new Error('Editor not initialized');

        this.editor.dispatch(this.editor.state.replaceSelection(text));
        return true;
    }

    getSelection() {
        if (!this.editor) return null;

        const selection = this.editor.state.selection.main;
        return {
            from: selection.from,
            to: selection.to,
            text: this.editor.state.doc.sliceString(selection.from, selection.to)
        };
    }

    focus() {
        if (!this.editor) throw new Error('Editor not initialized');

        this.editor.focus();
        return true;
    }

    executeCommand(command) {
        if (!this.editor) throw new Error('Editor not initialized');

        console.log('Executing command:', command);
        // 命令执行逻辑
        return true;
    }

    /**
     * 通信方法
     */
    sendEvent(event, data) {
        if (!this.communicationPort) {
            console.warn('Attempting to send event, but communication port is not available.');
            return;
        }
        try {
            const message = {
                type: 'event',
                event,
                data,
                timestamp: Date.now()
            };
            this.communicationPort.postMessage(JSON.stringify(message));
        } catch (error) {
            // 捕获异常
            console.error('sendEvent: Failed to send event via communication port:', error);
            // 设置端口为 null，防止后续尝试
            this.communicationPort = null;
        }
    }

    /**
     * 发送响应
     */
    sendResponse(id, data, error = null) {
        if (!this.communicationPort) {
            console.warn('Attempting to send response, but communication port is not available.');
            return;
        }
        try {
            const message = {
                type: 'response',
                id,
                data,
                error,
                timestamp: Date.now()
            };
            this.communicationPort.postMessage(JSON.stringify(message));
        } catch (error) {
            console.error('sendResponse: Failed to send response via communication port:', error);
            // 设置端口为 null，防止后续尝试
            this.communicationPort = null;
        }
    }

    /**
     * 错误处理
     */
    showError(message) {
        const editorElement = document.getElementById('editor');
        if (editorElement) {
            editorElement.innerHTML = `<div class="loading" style="color: #ff6b6b;">${message}</div>`;
        }
    }

    /**
     * 销毁编辑器（清理状态）
     */
    destroy() {
        if (this.editor) {
            this.editor.destroy();
            this.editor = null;
        }
        if (this.minimap) {
            this.minimap.destroy();
            this.minimap = null;
        }

        // 清理主题 Compartment
        this.themeCompartment = null;

        this.isInitialized = false;
        this.initializationInProgress = false;

        this.cachedModules = null;
        this.themeCache = null;
    }

    /**
     * 更新加载状态
     */
    updateLoadingStatus(message) {
        const editorElement = document.getElementById('editor');
        if (editorElement && editorElement.querySelector('.loading')) {
            editorElement.querySelector('.loading').textContent = message;
        }
        console.log('Loading status:', message);
    }

}

// 全局初始化
let editorInstance = null;

document.addEventListener('DOMContentLoaded', () => {
    console.log('DOM loaded, creating editor instance');
    // 创建实例并立即初始化通信
    editorInstance = new HarmonyCodeEditor();
});

// 全局API
window.editorAPI = {
    getInstance: () => editorInstance,
    // 添加手动初始化方法
    initialize: () => {
        if (editorInstance && !editorInstance.isInitialized) {
            return editorInstance.init();
        }
        return Promise.resolve();
    },
    destroy: () => {
        if (editorInstance) {
            editorInstance.destroy();
            editorInstance = null;
        }
    }
};
