---
title: Nail Design Assistant
layout: default
---

# Nail Design Assistant 💅

Nail Design Assistant is an iOS app for nail technicians.  
It helps techs generate AI-powered nail art ideas, manage clients, and schedule appointments in one place.

## 🎯 Project Overview

- **Platform:** iOS (SwiftUI)
- **Backend:** Firebase (Auth + Firestore), custom AI backend (Render + OpenAI image models)
- **Role:** Solo developer (Capstone project at CSU Channel Islands)
- **Goal:** Give nail techs a simple tool to:
  - Store client info and past designs  
  - Book and view appointments on a calendar  
  - Generate new nail design ideas with AI  

## ✨ Key Features

- **AI Design Helper** – type a prompt (e.g., *“sunset chrome almond nails”*) and get a nail-only design image.
- **Client Management** – add clients, store phone numbers, see their past designs.
- **Appointments Calendar** – schedule appointments and view them by date.
- **Design History** – save AI designs to specific clients for future reference.
- **Authentication** – secure login with Firebase Auth.

## 🧱 Tech Stack

- **Language:** Swift (SwiftUI)
- **IDE:** Xcode
- **Data:** Firebase Firestore (users, clients, appointments, designs)
- **Auth:** Firebase Auth (email + password)
- **AI Backend:** Custom endpoint on Render that wraps OpenAI image generation (DALL·E) with nail-specific prompts.

## 🧪 Challenges & What I Learned

- Designing a data model that keeps **users → clients → appointments → designs** connected in Firestore.
- Building a clean **TabView-based navigation** for Calendar, Clients, AI Helper, and Settings.
- Handling **live listeners** to keep the UI in sync with Firestore updates.
- Prompt-wrapping so the AI generator **only** returns nail designs (not random images).
- Managing real-world developer stuff like Git, multiple machines, and app icons.

## 📸 Screenshots

_(You can replace these with real images later.)_

![AI Helper Screen](assets/ai-helper.png)
![Clients Screen](assets/clients-screen.png)
![Calendar Screen](assets/calendar-screen.png)

## 🔗 Links

- **GitHub Repository:** _link to this repo_
- **Capstone Poster (PDF):** _link when available_

## 👩🏻‍💻 About the Developer

I’m **Zoe Hazan**, a Computer Science student at CSU Channel Islands, passionate about game dev, iOS apps, and combining tech with creativity. This project was built as my senior Capstone and is aimed at making life easier (and cuter) for nail techs.
