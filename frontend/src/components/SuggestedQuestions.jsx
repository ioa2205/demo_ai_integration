import React from 'react';

const SUGGESTIONS = {
  'ru-RU': [
    {
      category: 'Производство',
      icon: '⚙',
      questions: [
        'Статус производства на сегодня',
        'Покажи все партии',
      ],
    },
    {
      category: 'Склад',
      icon: '📦',
      questions: [
        'Что на складе?',
        'Остатки материалов',
      ],
    },
    {
      category: 'Продажи',
      icon: '💰',
      questions: [
        'Последние продажи',
        'Покажи клиентов',
      ],
    },
    {
      category: 'Продукция',
      icon: '📋',
      questions: [
        'Покажи все продукты',
        'Себестоимость продукции',
      ],
    },
  ],
  'uz-UZ': [
    {
      category: 'Ishlab chiqarish',
      icon: '⚙',
      questions: [
        'Bugungi ishlab chiqarish holati',
        'Barcha partiyalarni ko\'rsat',
      ],
    },
    {
      category: 'Ombor',
      icon: '📦',
      questions: [
        'Omborda nima bor?',
        'Materiallar qoldig\'i',
      ],
    },
    {
      category: 'Sotuvlar',
      icon: '💰',
      questions: [
        'Oxirgi sotuvlar',
        'Mijozlarni ko\'rsat',
      ],
    },
    {
      category: 'Mahsulotlar',
      icon: '📋',
      questions: [
        'Barcha mahsulotlarni ko\'rsat',
        'Mahsulot tannarxi',
      ],
    },
  ],
};

export default function SuggestedQuestions({ onSelect, lang }) {
  const items = SUGGESTIONS[lang] || SUGGESTIONS['ru-RU'];

  return (
    <div className="suggested-questions">
      <div className="sq-header">
        {lang === 'uz-UZ'
          ? 'Savollar bilan boshlang:'
          : 'Начните с вопроса:'}
      </div>
      <div className="sq-categories">
        {items.map((cat) => (
          <div key={cat.category} className="sq-category">
            <div className="sq-category-label">
              <span className="sq-icon">{cat.icon}</span>
              {cat.category}
            </div>
            <div className="sq-chips">
              {cat.questions.map((q) => (
                <button
                  key={q}
                  className="sq-chip"
                  onClick={() => onSelect(q)}
                >
                  {q}
                </button>
              ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
