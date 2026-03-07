import React, { useState, useCallback, useRef, useEffect } from 'react';
import ChatPanel from './ChatPanel';
import ToolStatus from './ToolStatus';
import VoiceInput from './VoiceInput';

export default function ChatWidget() {
  const [isOpen, setIsOpen] = useState(false);
  const STORAGE_KEY = 'factory_chat_history';
  const ACTIVITY_KEY = 'factory_chat_last_activity';
  const EXPIRY_MS = 48 * 60 * 60 * 1000; // 48 hours

  const [messages, setMessages] = useState(() => {
    try {
      const lastActivity = parseInt(localStorage.getItem(ACTIVITY_KEY) || '0', 10);
      if (lastActivity && (Date.now() - lastActivity) > EXPIRY_MS) {
        localStorage.removeItem(STORAGE_KEY);
        localStorage.removeItem(ACTIVITY_KEY);
        return [];
      }
      const saved = localStorage.getItem(STORAGE_KEY);
      return saved ? JSON.parse(saved) : [];
    } catch { return []; }
  });
  const [isLoading, setIsLoading] = useState(false);
  const [currentTool, setCurrentTool] = useState(null);
  const [lang, setLang] = useState('ru-RU');
  const [ttsEnabled, setTtsEnabled] = useState(true);
  const [isSpeaking, setIsSpeaking] = useState(false);
  const audioRef = useRef(null);

  // Persist chat history + activity timestamp to localStorage
  useEffect(() => {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(messages.slice(-50)));
      if (messages.length > 0) {
        localStorage.setItem(ACTIVITY_KEY, String(Date.now()));
      }
    } catch {}
  }, [messages]);

  const clearHistory = useCallback(() => {
    setMessages([]);
    localStorage.removeItem(STORAGE_KEY);
    localStorage.removeItem(ACTIVITY_KEY);
  }, []);

  const playAudio = useCallback((base64Wav) => {
    if (!ttsEnabled || !base64Wav) return;

    if (audioRef.current) { audioRef.current.pause(); audioRef.current = null; }

    const audio = new Audio(`data:audio/wav;base64,${base64Wav}`);
    audio.onplay = () => setIsSpeaking(true);
    audio.onended = () => setIsSpeaking(false);
    audio.onerror = () => setIsSpeaking(false);
    audioRef.current = audio;
    audio.play();
  }, [ttsEnabled]);

  const stopSpeaking = useCallback(() => {
    if (audioRef.current) { audioRef.current.pause(); audioRef.current = null; }
    setIsSpeaking(false);
  }, []);

  const toggleTts = useCallback(() => {
    if (ttsEnabled) stopSpeaking();
    setTtsEnabled((prev) => !prev);
  }, [ttsEnabled, stopSpeaking]);

  const sendMessage = useCallback(async (text) => {
    setMessages((prev) => [...prev, { role: 'user', text }]);
    setIsLoading(true);
    setCurrentTool('thinking');

    try {
      const res = await fetch('/api/agent_bridge.php', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          message: text,
          lang,
          history: messages.slice(-10).map(m => ({ role: m.role, text: m.text })),
        }),
      });
      const json = await res.json();

      if (json.tool_calls?.length) {
        setCurrentTool(json.tool_calls[json.tool_calls.length - 1].name);
      }

      const reply = json.reply || json.error || 'No response';

      setMessages((prev) => [
        ...prev,
        {
          role: 'assistant',
          text: reply,
          toolCalls: json.tool_calls,
          data: json.data,
        },
      ]);

      playAudio(json.audio);
    } catch (err) {
      setMessages((prev) => [
        ...prev,
        { role: 'assistant', text: 'Ошибка соединения с сервером.' },
      ]);
    } finally {
      setIsLoading(false);
      setTimeout(() => setCurrentTool(null), 2000);
    }
  }, [lang, playAudio, messages]);

  return (
    <>
      {!isOpen && (
        <button className="chat-fab" onClick={() => setIsOpen(true)} title="AI Yordamchi">
          <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <path d="M12 2a2 2 0 0 1 2 2c0 .74-.4 1.39-1 1.73V7h1a7 7 0 0 1 7 7h1a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1h-1.27A7 7 0 0 1 14 22h-4a7 7 0 0 1-6.73-3H2a1 1 0 0 1-1-1v-3a1 1 0 0 1 1-1h1a7 7 0 0 1 7-7h1V5.73c-.6-.34-1-.99-1-1.73a2 2 0 0 1 2-2z"/>
            <circle cx="9.5" cy="14.5" r="1.5"/>
            <circle cx="14.5" cy="14.5" r="1.5"/>
          </svg>
        </button>
      )}

      {isOpen && (
        <div className="chat-widget">
          <div className="chat-widget-header">
            <div className="chat-widget-title">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M12 2a2 2 0 0 1 2 2c0 .74-.4 1.39-1 1.73V7h1a7 7 0 0 1 7 7h1a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1h-1.27A7 7 0 0 1 14 22h-4a7 7 0 0 1-6.73-3H2a1 1 0 0 1-1-1v-3a1 1 0 0 1 1-1h1a7 7 0 0 1 7-7h1V5.73c-.6-.34-1-.99-1-1.73a2 2 0 0 1 2-2z"/>
                <circle cx="9.5" cy="14.5" r="1.5"/>
                <circle cx="14.5" cy="14.5" r="1.5"/>
              </svg>
              <span>AI Yordamchi</span>
            </div>
            <div className="chat-widget-actions">
              <button
                className={`tts-toggle ${ttsEnabled ? 'active' : ''} ${isSpeaking ? 'speaking' : ''}`}
                onClick={isSpeaking ? stopSpeaking : toggleTts}
                title={isSpeaking ? 'Stop speaking' : ttsEnabled ? 'Disable voice' : 'Enable voice'}
              >
                {isSpeaking ? (
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
                    <rect x="6" y="6" width="12" height="12" rx="2" />
                  </svg>
                ) : ttsEnabled ? (
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                    <polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5" />
                    <path d="M15.54 8.46a5 5 0 0 1 0 7.07" />
                    <path d="M19.07 4.93a10 10 0 0 1 0 14.14" />
                  </svg>
                ) : (
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                    <polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5" />
                    <line x1="23" y1="9" x2="17" y2="15" />
                    <line x1="17" y1="9" x2="23" y2="15" />
                  </svg>
                )}
              </button>
              <button
                className="tts-toggle"
                onClick={clearHistory}
                title="Clear chat history"
              >
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <polyline points="3 6 5 6 21 6" />
                  <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" />
                </svg>
              </button>
              <button className="chat-widget-close" onClick={() => { stopSpeaking(); setIsOpen(false); }}>
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <line x1="18" y1="6" x2="6" y2="18"/>
                  <line x1="6" y1="6" x2="18" y2="18"/>
                </svg>
              </button>
            </div>
          </div>
          <ChatPanel messages={messages} isLoading={isLoading} onSend={sendMessage} lang={lang} />
          <ToolStatus toolName={currentTool} />
          <VoiceInput onSend={sendMessage} disabled={isLoading} lang={lang} onLangChange={setLang} />
        </div>
      )}
    </>
  );
}
