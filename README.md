# ShopNow Order Management API

A production-grade RESTful API for managing users, products, and orders for the ShopNow e-commerce platform.

## Tech Stack
- **Runtime**: Node.js 18+
- **Framework**: Express.js 4.x
- **Database**: MongoDB (via Mongoose ODM)
- **Auth**: JWT (JSON Web Tokens) + bcryptjs
- **Testing**: Jest + Supertest

## Project Structure
```
src/
  app.js                 # Express application entry point
  config/
    constants.js         # Application-wide constants & limits
    database.js          # MongoDB connection with retry logic
  controllers/           # Route handler functions (thin layer)
  middleware/
    errorHandler.js      # Centralized error handling middleware
  models/                # Mongoose schemas and models
  routes/                # Express route definitions
  services/              # Business logic layer (fat services)
tests/                   # Jest test suites (unit + integration)
```

## Git Assignment Branches
| Branch | Skill | Description |
|---|---|---|
| `feature/amend-me` | `git commit --amend` | Fix a bad commit: leaked secrets, missing file, debug logs |
| `feature/dependent-feature` | `git merge/rebase` | Sync with base branch security patch (route conflict) |
| `feature/merge-conflict` | `git merge` | Resolve 5-file conflict between pagination and caching refactors |
| `feature/rebase-me` | `git rebase` | Rebase discount feature onto main (3-file conflict) |
| `feature/squash-me` | `git rebase -i` | Squash 12 messy payment sprint commits into 1 clean commit |
| `feature/cherry-pick` | `git cherry-pick` | Pick a critical bug fix from another branch without bringing experimental code |

## Getting Started
```bash
npm install
cp .env.example .env
# Fill in MONGO_URI and JWT_SECRET in .env
npm run dev
```
