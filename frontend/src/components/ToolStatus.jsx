import React from 'react';

const TOOL_LABELS = {
  thinking: 'AI думает...',
  execute_sql: 'Выполнение SQL запроса...',
};

export default function ToolStatus({ toolName }) {
  if (!toolName) return null;

  return (
    <div className="tool-status">
      <div className="tool-status-bar" />
      <span className="tool-status-label">
        {TOOL_LABELS[toolName] || `${toolName}...`}
      </span>
      <span className="tool-status-fn">{toolName}</span>
    </div>
  );
}
