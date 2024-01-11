こちらは「SwipeEats」のバックエンドのリポジトリになります。
フロントエンドのリポジトリは[こちら](https://github.com/GorillaSwe/swipe-eats-frontend)です。

# SwipeEats

SwipeEats はレストランを簡単に探せる、無料のWebアプリケーションです。

ユーザーはスワイプすることでレストランを選び、お気に入りの店を見つけることができます。

### ▼ サービスURL

https://www.swipeeats.net/

レスポンシブ対応済のため、PCでもスマートフォンでも快適にご利用いただけます。

## 技術スタック

**バックエンド:** Ruby 3.0.6 / Rails 7.0.7.2

- テストフレームワーク: Minitest
- 主要パッケージ: JWT / Kaminari / Google Places

**フロントエンド:** TypeScript 5.2.2 / React 18.2.0 / Next.js 13.5.4

- コード解析: ESLint
- フォーマッター: Prettier
- テストフレームワーク: Jest / React Testing Library
- スタイリング: CSS Modules / SCSS
- 主要パッケージ: Axios / Material UI / React Tinder Card / React Infinite Scroller
  / React Slick

**インフラ:** Vercel / Render / PlanetScale

**CI / CD:** GitHub Actions

**環境構築:** Docker / Docker Compose

**認証:** Auth0

**死活監視:** Uptime Robot

**マップサービス:** Google Maps API

## 主要な対応

Swipe Eatsでは、ユーザーに最適なレストラン検索体験を提供するために、以下の主要な機能と技術的対応を実装しています。

### 機能

- レストランのスワイプ機能: ユーザーはスワイプ操作でレストランを「Like」または「Nope」することができます。
- お気に入りのレストラン管理: 「Like」したレストランはお気に入りリストに追加され、後で閲覧可能です。
- 地図上でのレストラン表示: レストランは地図上に表示され、ユーザーは場所に基づいてレストランを探索できます。
- レスポンシブデザイン: スマートフォン、タブレット、デスクトップなど、異なるデバイスでスムーズに利用できます。
- ユーザー認証: Auth0を使用したセキュアなログインとサインアップ機能を提供します。

### 技術的対応

- UIコンポーネント: React Tinder CardとReact Slickを用いたインタラクティブなUI。
- 認証: Auth0による安全な認証とユーザー管理。
- 地図表示: Google Maps APIを使用したインタラクティブな地図表示。
- インフラストラクチャ: Dockerによる開発環境のコンテナ化。
- CI / CD: GitHub ActionsによるCI / CDパイプラインの構築

## ER図

![er-diagram](https://raw.githubusercontent.com/GorillaSwe/swipe-eats-frontend/main/public/images/erd.png)
