
export function replaceKeyByValue<K, V>(map: Map<K, V>, targetValue: V, newKey: K): boolean {
    for (const [key, value] of map.entries()) {
        if (value === targetValue) {
            if (key !== newKey) {
                map.delete(key);
                map.set(newKey, targetValue);
            }
            return true;
        }
    }
    return false;
}