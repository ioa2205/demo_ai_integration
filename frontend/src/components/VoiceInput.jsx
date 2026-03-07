import React, { useState, useRef, useCallback } from 'react';

const SpeechRecognition =
  window.SpeechRecognition || window.webkitSpeechRecognition;

export default function VoiceInput({ onSend, disabled, lang, onLangChange }) {
  const [text, setText] = useState('');
  const [isListening, setIsListening] = useState(false);
  const recognitionRef = useRef(null);
  const finalTranscriptRef = useRef('');

  const startListening = useCallback(() => {
    if (!SpeechRecognition) {
      alert('Браузер не поддерживает распознавание речи. Используйте Chrome.');
      return;
    }
    if (disabled) return;

    finalTranscriptRef.current = '';

    const recognition = new SpeechRecognition();
    recognition.lang = lang;
    recognition.interimResults = true;
    recognition.continuous = false;

    recognition.onstart = () => setIsListening(true);

    recognition.onresult = (event) => {
      let interim = '';
      let final = '';
      for (let i = 0; i < event.results.length; i++) {
        const result = event.results[i];
        if (result.isFinal) {
          final += result[0].transcript;
        } else {
          interim += result[0].transcript;
        }
      }
      finalTranscriptRef.current = final;
      setText(final || interim);
    };

    recognition.onend = () => {
      setIsListening(false);
      // Auto-send when voice recording ends with recognized text
      const transcript = finalTranscriptRef.current.trim();
      if (transcript) {
        onSend(transcript);
        setText('');
        finalTranscriptRef.current = '';
      }
    };

    recognition.onerror = (e) => {
      setIsListening(false);
      if (e.error !== 'no-speech' && e.error !== 'aborted') {
        console.error('Speech recognition error:', e.error);
      }
    };

    recognitionRef.current = recognition;
    recognition.start();
  }, [lang, disabled, onSend]);

  const stopListening = useCallback(() => {
    recognitionRef.current?.stop();
  }, []);

  const handleSubmit = (e) => {
    e.preventDefault();
    if (text.trim() && !disabled) {
      onSend(text.trim());
      setText('');
    }
  };

  return (
    <form className="voice-input" onSubmit={handleSubmit}>
      <div className="lang-toggle">
        <button
          type="button"
          className={lang === 'ru-RU' ? 'active' : ''}
          onClick={() => onLangChange('ru-RU')}
        >
          RU
        </button>
        <button
          type="button"
          className={lang === 'uz-UZ' ? 'active' : ''}
          onClick={() => onLangChange('uz-UZ')}
        >
          UZ
        </button>
      </div>
      <input
        type="text"
        value={text}
        onChange={(e) => setText(e.target.value)}
        placeholder={
          lang === 'ru-RU'
            ? 'Говорите или введите текст...'
            : 'Gapiring yoki yozing...'
        }
        disabled={disabled}
      />
      <button
        type="button"
        className={`mic-btn ${isListening ? 'listening' : ''}`}
        onMouseDown={startListening}
        onMouseUp={stopListening}
        onMouseLeave={stopListening}
        disabled={disabled}
        title={lang === 'ru-RU' ? 'Удерживайте для записи' : "Bosib turing"}
      >
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <path d="M12 1a3 3 0 0 0-3 3v8a3 3 0 0 0 6 0V4a3 3 0 0 0-3-3z"/>
          <path d="M19 10v2a7 7 0 0 1-14 0v-2"/>
          <line x1="12" y1="19" x2="12" y2="23"/>
          <line x1="8" y1="23" x2="16" y2="23"/>
        </svg>
      </button>
      <button
        type="submit"
        className="send-btn"
        disabled={disabled || !text.trim()}
        title={lang === 'ru-RU' ? 'Отправить' : 'Yuborish'}
      >
        <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
          <path d="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z"/>
        </svg>
      </button>
    </form>
  );
}
