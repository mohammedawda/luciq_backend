# Luciq Backend Challenge

## Overview

This project is a **chat system API** built with **Ruby on Rails**, designed to handle high concurrency and scalability.  
It supports creating applications, chats, and messages — each linked hierarchically — while maintaining asynchronous persistence using **Sidekiq** and **Redis** to minimize direct database writes during API requests.

The system ensures unique incremental numbering for chats and messages within their respective scopes, safely handling concurrent requests across distributed instances.

---

## 🧱 Architecture

The system follows a **modular, event-driven architecture** with the following key components:

- **Ruby on Rails** — Main API and business logic.
- **MySQL** — Primary relational datastore.
- **Redis** — Used for atomic counters and Sidekiq job queuing.
- **Sidekiq** — Handles background persistence of chats and messages asynchronously.
- **Docker Compose** — Provides a fully containerized environment for local setup.

---

## 🧩 Core Entities

| Entity | Description |
|--------|--------------|
| **Application** | Represents a registered app that owns multiple chats. Identified by a system-generated `token`. |
| **Chat** | Belongs to an application. Each chat has a unique sequential `number` starting from 1 per application. |
| **Message** | Belongs to a chat. Each message has a unique sequential `number` starting from 1 per chat. |

Both `chats_count` and `messages_count` are cached counters that may lag slightly (up to 1 hour) but are eventually consistent.

---

## ⚙️ Endpoints

### **Applications**

| Method | Endpoint | Description |
|--------|-----------|-------------|
| `POST` | `/applications` | Create a new application (auto-generates token). |
| `GET` | `/applications` | List all applications. |
| `GET` | `/applications/:token` | Retrieve application details. |
| `PUT` | `/applications/:token` | Update application name. |

### **Chats**

| Method | Endpoint | Description |
|--------|-----------|-------------|
| `POST` | `/applications/:token/chats` | Create a new chat for the given application (returns chat number immediately). |
| `GET` | `/applications/:token/chats` | List all chats for an application. |
| `GET` | `/applications/:token/chats/:chat_number` | get chat stats of message count by chat number. |

> ✅ Chat creation uses Redis to allocate the next chat number instantly and Sidekiq to persist it asynchronously.

### **Messages**

| Method | Endpoint | Description |
|--------|-----------|-------------|
| `POST` | `/applications/:token/chats/:number/messages` | Create a new message under a specific chat (returns message number immediately). |
| `GET` | `/applications/:token/chats/:number/messages` | Retrieve all messages for a given chat. |
| `GET` | `/applications/:token/chats/:number/messages/:message_number` | Retrieve message details. |
| `GET` | `/applications/:token/chats/:number/messages/search?q=test` | search in chat messages using elastic search. |


> ✅ Message creation also uses Redis + Sidekiq for high concurrency safety.

---

## 🧠 Asynchronous Processing

- When a chat or message is created:
  1. A **Redis counter** generates the next sequential number.
  2. The request immediately returns that number (non-blocking).
  3. A **Sidekiq worker** (`CreateChatWorker` or `CreateMessageWorker`) persists the record into MySQL asynchronously.

This approach prevents race conditions and allows the API to remain highly performant under load.

---

## 🚀 Setup Instructions

### **1. Clone the repository**

```bash
git clone https://github.com/your-username/luciq_backend.git
cd luciq_backend

```To start everything, simply run:
docker-compose up --build
docker-compose exec app bash
rails db:create db:migrate
exit

🧾 License

This project was developed as part of the Luciq Backend Challenge.
All rights reserved © 2025.