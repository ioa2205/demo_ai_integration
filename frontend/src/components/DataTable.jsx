import React from 'react';

function renderTable(rows) {
  if (!rows || rows.length === 0) return <p className="no-data">Нет данных</p>;

  const columns = Object.keys(rows[0]).filter(
    (c) => typeof rows[0][c] !== 'object' || rows[0][c] === null
  );

  return (
    <div className="table-scroll">
      <table className="data-table">
        <thead>
          <tr>
            {columns.map((c) => (
              <th key={c}>{c}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.map((row, i) => (
            <tr key={i}>
              {columns.map((c) => (
                <td key={c}>{String(row[c] ?? '-')}</td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export default function DataTable({ data, compact = false }) {
  if (!data) {
    if (compact) return null;
    return (
      <div className="data-table-empty">
        <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
          <rect x="3" y="3" width="18" height="18" rx="2" ry="2"/>
          <line x1="3" y1="9" x2="21" y2="9"/>
          <line x1="3" y1="15" x2="21" y2="15"/>
          <line x1="9" y1="3" x2="9" y2="21"/>
        </svg>
        <p>Данные появятся после запроса к AI</p>
        <p>AI ga so'rov yuborgandan keyin ma'lumotlar ko'rinadi</p>
      </div>
    );
  }

  const wrapperClass = compact
    ? 'data-table-wrapper data-table-compact'
    : 'data-table-wrapper';

  // Simple array of flat objects
  if (Array.isArray(data)) {
    return <div className={wrapperClass}>{renderTable(data)}</div>;
  }

  // Nested object (e.g. get_product_detail or get_production_stats)
  return (
    <div className={wrapperClass}>
      {Object.entries(data).map(([key, value]) => {
        if (Array.isArray(value)) {
          return (
            <div key={key} className="data-section">
              <h3>{key}</h3>
              {renderTable(value)}
            </div>
          );
        }
        if (value && typeof value === 'object') {
          return (
            <div key={key} className="data-section">
              <h3>{key}</h3>
              <div className="kv-grid">
                {Object.entries(value).map(([k, v]) => (
                  <React.Fragment key={k}>
                    <span className="kv-key">{k}</span>
                    <span className="kv-val">{String(v ?? '-')}</span>
                  </React.Fragment>
                ))}
              </div>
            </div>
          );
        }
        return (
          <div key={key} className="data-section data-field">
            <span className="kv-key">{key}</span>
            <span className="kv-val">{String(value ?? '-')}</span>
          </div>
        );
      })}
    </div>
  );
}
