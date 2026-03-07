import React, { useState, useEffect } from 'react';

export default function Dashboard() {
  const [products, setProducts] = useState(null);
  const [stock, setStock] = useState(null);
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    async function loadDashboard() {
      try {
        const res = await fetch('/api/agent_bridge.php');
        const data = await res.json();
        setProducts(data.products);
        setStock(data.stock);
        setStats(data.stats);
      } catch (err) {
        setError('Не удалось загрузить данные / Ma\'lumotlarni yuklab bo\'lmadi');
      } finally {
        setLoading(false);
      }
    }
    loadDashboard();
  }, []);

  if (loading) {
    return (
      <div className="dashboard-loading">
        <div className="dashboard-spinner" />
        <p>Загрузка данных... / Ma'lumotlar yuklanmoqda...</p>
      </div>
    );
  }

  if (error) {
    return <div className="dashboard-error">{error}</div>;
  }

  const summary = stats?.summary;

  return (
    <div className="dashboard">
      <div className="dashboard-stats">
        <div className="stat-card">
          <div className="stat-value">{products?.length ?? 0}</div>
          <div className="stat-label">Mahsulotlar / Продукция</div>
        </div>
        <div className="stat-card">
          <div className="stat-value">{summary?.in_progress_count ?? 0}</div>
          <div className="stat-label">Jarayonda / В процессе</div>
        </div>
        <div className="stat-card">
          <div className="stat-value">{summary?.completed_count ?? 0}</div>
          <div className="stat-label">Tayyor / Завершено</div>
        </div>
        <div className="stat-card">
          <div className="stat-value">{summary?.pending_count ?? 0}</div>
          <div className="stat-label">Kutilmoqda / Ожидание</div>
        </div>
      </div>

      <div className="dashboard-grid">
        <div className="dashboard-card">
          <h3>Mahsulotlar / Продукция</h3>
          {products && products.length > 0 ? (
            <div className="table-scroll">
              <table className="data-table">
                <thead>
                  <tr>
                    <th>ID</th>
                    <th>Nomi / Название</th>
                    <th>Kategoriya / Категория</th>
                    <th>Birlik / Единица</th>
                  </tr>
                </thead>
                <tbody>
                  {products.map((p) => (
                    <tr key={p.id}>
                      <td>{p.id}</td>
                      <td>{p.name}</td>
                      <td>{p.category_name ?? '-'}</td>
                      <td>{p.unit_name ?? '-'}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          ) : (
            <p className="no-data">Нет данных</p>
          )}
        </div>

        <div className="dashboard-card">
          <h3>Ombor holati / Складские остатки</h3>
          {stock && stock.length > 0 ? (
            <div className="table-scroll">
              <table className="data-table">
                <thead>
                  <tr>
                    <th>Turi / Тип</th>
                    <th>Nomi / Название</th>
                    <th>Miqdor / Кол-во</th>
                    <th>Ombor / Склад</th>
                  </tr>
                </thead>
                <tbody>
                  {stock.map((s, i) => (
                    <tr key={i}>
                      <td>{s.item_type}</td>
                      <td>{s.item_name}</td>
                      <td>{s.qty} {s.unit_code}</td>
                      <td>{s.warehouse_name}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          ) : (
            <p className="no-data">Нет данных</p>
          )}
        </div>

        <div className="dashboard-card">
          <h3>Ishlab chiqarish / Производство</h3>
          {stats?.by_status && stats.by_status.length > 0 ? (
            <div className="table-scroll">
              <table className="data-table">
                <thead>
                  <tr>
                    <th>Holat / Статус</th>
                    <th>Soni / Кол-во</th>
                    <th>Reja / План</th>
                    <th>Fakt / Факт</th>
                  </tr>
                </thead>
                <tbody>
                  {stats.by_status.map((s, i) => (
                    <tr key={i}>
                      <td>{s.status}</td>
                      <td>{s.cnt}</td>
                      <td>{s.total_plan ?? '-'}</td>
                      <td>{s.total_fact ?? '-'}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          ) : (
            <p className="no-data">Нет данных</p>
          )}

          {stats?.today_completed && stats.today_completed.length > 0 && (
            <>
              <h3 style={{ marginTop: '16px' }}>Bugun tayyor / Завершено сегодня</h3>
              <div className="table-scroll">
                <table className="data-table">
                  <thead>
                    <tr>
                      <th>Partiya / Партия</th>
                      <th>Mahsulot / Продукт</th>
                      <th>Reja / План</th>
                      <th>Fakt / Факт</th>
                    </tr>
                  </thead>
                  <tbody>
                    {stats.today_completed.map((b, i) => (
                      <tr key={i}>
                        <td>{b.batch_no}</td>
                        <td>{b.product_name}</td>
                        <td>{b.plan_qty}</td>
                        <td>{b.fact_qty}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
