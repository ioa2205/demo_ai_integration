import React from 'react';
import Dashboard from './components/Dashboard';
import ChatWidget from './components/ChatWidget';

export default function App() {
  return (
    <div className="app-container">
      <header className="app-header">
        <h1>AI Zavod Yordamchisi</h1>
        <span className="subtitle">
          Ishlab chiqarish boshqaruv tizimi | Система управления производством
        </span>
      </header>
      <main className="app-main">
        <Dashboard />
      </main>
      <ChatWidget />
    </div>
  );
}
