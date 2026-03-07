<?php

require_once __DIR__ . '/config.php';

/**
 * Returns list of all active products with category and unit info.
 */
function get_product_list(): array
{
    $db = getDB();
    $sql = "
        SELECT
            p.id,
            p.name,
            p.spec,
            pc.name AS category_name,
            ru.code AS unit_code,
            ru.name AS unit_name,
            p.status,
            FROM_UNIXTIME(p.created_at, '%Y-%m-%d %H:%i') AS created_at
        FROM product p
        LEFT JOIN product_category pc ON pc.id = p.category_id
        LEFT JOIN ref_unit ru ON ru.id = p.unit_id
        WHERE p.status = 1
        ORDER BY p.id
    ";
    return $db->query($sql)->fetchAll();
}

/**
 * Returns full detail for one product: stock, recipe, price, packaging.
 */
function get_product_detail(int $id): array
{
    $db = getDB();

    $stmt = $db->prepare("
        SELECT p.id, p.name, p.spec, p.note,
               pc.name AS category_name,
               ru.code AS unit_code, ru.name AS unit_name
        FROM product p
        LEFT JOIN product_category pc ON pc.id = p.category_id
        LEFT JOIN ref_unit ru ON ru.id = p.unit_id
        WHERE p.id = ?
    ");
    $stmt->execute([$id]);
    $product = $stmt->fetch();
    if (!$product) {
        return ['error' => 'Product not found'];
    }

    // Stock across warehouses
    $stmt = $db->prepare("
        SELECT s.qty, w.name AS warehouse_name, w.wh_type
        FROM stock s
        JOIN warehouse w ON w.id = s.warehouse_id
        WHERE s.item_type = 'PRODUCT' AND s.item_id = ?
    ");
    $stmt->execute([$id]);
    $product['stock'] = $stmt->fetchAll();

    // Active recipe with materials
    $stmt = $db->prepare("
        SELECT r.id AS recipe_id, r.name AS recipe_name, r.version,
               ri.material_id, m.name AS material_name,
               ri.qty AS material_qty, ri.waste_percent,
               mu.code AS material_unit
        FROM recipe r
        JOIN recipe_item ri ON ri.recipe_id = r.id
        JOIN material m ON m.id = ri.material_id
        LEFT JOIN ref_unit mu ON mu.id = m.unit_id
        WHERE r.product_id = ? AND r.is_main = 1 AND r.status = 1
    ");
    $stmt->execute([$id]);
    $product['recipe'] = $stmt->fetchAll();

    // Current price
    $stmt = $db->prepare("
        SELECT price, currency, valid_from
        FROM price
        WHERE item_type = 'PRODUCT' AND item_id = ? AND status = 1
        ORDER BY valid_from DESC LIMIT 1
    ");
    $stmt->execute([$id]);
    $product['price'] = $stmt->fetch() ?: null;

    // Packaging options
    $stmt = $db->prepare("
        SELECT pp.name, pp.capacity_qty, ru.code AS unit_code, pp.is_default
        FROM product_packaging pp
        LEFT JOIN ref_unit ru ON ru.id = pp.unit_id
        WHERE pp.product_id = ? AND pp.status = 1
    ");
    $stmt->execute([$id]);
    $product['packaging'] = $stmt->fetchAll();

    return $product;
}

/**
 * Returns stock levels for all items across all warehouses.
 */
function get_stock_overview(): array
{
    $db = getDB();
    $sql = "
        SELECT
            s.item_type,
            s.qty,
            w.name AS warehouse_name,
            w.wh_type,
            CASE
                WHEN s.item_type = 'PRODUCT' THEN p.name
                WHEN s.item_type = 'MATERIAL' THEN m.name
            END AS item_name,
            CASE
                WHEN s.item_type = 'PRODUCT' THEN pu.code
                WHEN s.item_type = 'MATERIAL' THEN mu.code
            END AS unit_code,
            FROM_UNIXTIME(s.updated_at, '%Y-%m-%d %H:%i') AS last_updated
        FROM stock s
        JOIN warehouse w ON w.id = s.warehouse_id
        LEFT JOIN product p ON s.item_type = 'PRODUCT' AND p.id = s.item_id
        LEFT JOIN ref_unit pu ON p.unit_id = pu.id
        LEFT JOIN material m ON s.item_type = 'MATERIAL' AND m.id = s.item_id
        LEFT JOIN ref_unit mu ON m.unit_id = mu.id
        ORDER BY s.item_type, s.item_id
    ";
    return $db->query($sql)->fetchAll();
}

/**
 * Returns production statistics: batches by status, today's completed, plan vs actual.
 */
function get_production_stats(): array
{
    $db = getDB();

    $statusCounts = $db->query("
        SELECT status, COUNT(*) AS cnt,
               SUM(plan_qty) AS total_plan,
               SUM(fact_qty) AS total_fact
        FROM production_batch
        GROUP BY status
    ")->fetchAll();

    $todayStart = strtotime('today');
    $todayEnd = $todayStart + 86400;
    $stmt = $db->prepare("
        SELECT pb.batch_no, p.name AS product_name,
               pb.plan_qty, pb.fact_qty,
               FROM_UNIXTIME(pb.finished_at, '%Y-%m-%d %H:%i') AS finished_at
        FROM production_batch pb
        JOIN product p ON p.id = pb.product_id
        WHERE pb.status = 'COMPLETED'
          AND pb.finished_at >= ? AND pb.finished_at < ?
    ");
    $stmt->execute([$todayStart, $todayEnd]);
    $todayCompleted = $stmt->fetchAll();

    $summary = $db->query("
        SELECT
            COUNT(*) AS total_batches,
            SUM(plan_qty) AS total_plan_qty,
            SUM(fact_qty) AS total_fact_qty,
            SUM(CASE WHEN status = 'COMPLETED' THEN 1 ELSE 0 END) AS completed_count,
            SUM(CASE WHEN status = 'IN_PROGRESS' THEN 1 ELSE 0 END) AS in_progress_count,
            SUM(CASE WHEN status = 'PENDING' THEN 1 ELSE 0 END) AS pending_count
        FROM production_batch
    ")->fetch();

    return [
        'by_status'       => $statusCounts,
        'today_completed' => $todayCompleted,
        'summary'         => $summary,
    ];
}

/**
 * Updates a product's name or spec field only. Whitelist enforced.
 */
function update_product_field(int $id, string $field, string $value): array
{
    $allowed = ['name', 'spec'];
    if (!in_array($field, $allowed, true)) {
        return [
            'success' => false,
            'error'   => "Field '$field' is not allowed. Only: " . implode(', ', $allowed),
        ];
    }

    $db = getDB();

    $stmt = $db->prepare("SELECT id, name, spec FROM product WHERE id = ?");
    $stmt->execute([$id]);
    $before = $stmt->fetch();
    if (!$before) {
        return ['success' => false, 'error' => 'Product not found'];
    }

    $oldValue = $before[$field];
    $stmt = $db->prepare("UPDATE product SET `$field` = ?, updated_at = ? WHERE id = ?");
    $stmt->execute([$value, time(), $id]);

    return [
        'success'    => true,
        'product_id' => $id,
        'field'      => $field,
        'old_value'  => $oldValue,
        'new_value'  => $value,
    ];
}
