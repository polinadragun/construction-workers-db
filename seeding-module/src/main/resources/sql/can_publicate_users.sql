SELECT u.id, ur.role_code
FROM users u
JOIN user_roles ur ON u.id = ur.user_id
WHERE ur.role_code IN ('customer', 'gencontractor', 'contractor')