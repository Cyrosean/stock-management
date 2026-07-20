# Wholesale Inventory App

A Flutter app for managing a wholesale business: clients, suppliers,
purchases (stock coming in), inventory, and sales.

## Modules
- **Clients** — buyers you sell to
- **Suppliers** — vendors you buy stock from
- **Purchases** — stock-in records, linked to a supplier
- **Inventory** — current stock levels, units, and prices
- **Sales** — stock-out records, linked to a client
- **Profile** — business info

## Backend
PHP + MySQL API is expected at `ApiConfig.baseUrl` (see `lib/config.dart`).
See `wholesale_api/schema.sql` for the database schema and `wholesale_api/`
for the PHP endpoints.

If your PC's local IP changes, update `lib/config.dart` — that's the only
place it's referenced now.
