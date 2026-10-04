# Phase 9 Research: Dynamic Discovery Home, Albums & Singers Catalog

## Patterns and Best Practices

### 1. Multi-Lane Discovery Layout
- Use `CustomScrollView` with `SliverAppBar`, `SliverToBoxAdapter` for hero banners and horizontal carousels, and `SliverList` for recently played tracks.
- Pull-to-refresh (`RefreshIndicator`) invalidates the discovery providers.

### 2. Provider Architecture
- `hymnOfTheDayProvider`: `FutureProvider<Hymn?>`
- `featuredSingersProvider`: `FutureProvider<List<Singer>>`
- `featuredAlbumsProvider`: `FutureProvider<List<Album>>`
- `singerDetailProvider(id)`: `FutureProvider.family<List<Hymn>, String>`
- `albumDetailProvider(id)`: `FutureProvider.family<List<Hymn>, String>`

### 3. Graceful Offline Handling
- When network request throws (e.g. `SocketException` or offline timeout), providers fall back to `localHymnCache` or return empty lists rather than crashing UI.
- Home screen shows a banner: "أنت في وضع عدم الاتصال — استمع للترانيم المحملة" when disconnected.
