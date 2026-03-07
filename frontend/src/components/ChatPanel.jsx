import React, { useEffect, useRef } from 'react';
import DataTable from './DataTable';
import SuggestedQuestions from './SuggestedQuestions';

export default function ChatPanel({ messages, isLoading, onSend, lang }) {
  const bottomRef = useRef(null);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages, isLoading]);

  return (
    <div className="chat-panel">
      {messages.length === 0 && (
        <SuggestedQuestions onSelect={onSend} lang={lang} />
      )}
      {messages.map((msg, i) => (
        <div key={i} className={`chat-msg ${msg.role}`}>
          <div className="msg-label">
            {msg.role === 'user' ? 'Вы' : 'AI'}
          </div>
          <div className="msg-text">{msg.text}</div>
          {msg.data && (
            <div className="msg-data">
              <DataTable data={msg.data} compact />
            </div>
          )}
        </div>
      ))}
      {isLoading && (
        <div className="chat-msg assistant">
          <div className="msg-label">AI</div>
          <div className="msg-text typing">
            <span className="dot" />
            <span className="dot" />
            <span className="dot" />
          </div>
        </div>
      )}
      <div ref={bottomRef} />
    </div>
  );
}
