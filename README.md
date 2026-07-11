# ALU Hub

ALU Hub is a Flutter and Firebase application that connects ALU students with student-led startups.

Students can discover opportunities, save them, apply, and track their application progress. Startups can create opportunities, manage applicants, and update application status. An Admin verifies startup accounts before they are allowed to post opportunities.

## Project Information

- **Project Name:** ALU Hub
- **Project Type:** Individual Flutter Final Project
- **Student Name:** Liliane Dushimimana
- **Institution:** African Leadership University
- **Course Deliverable:** Formative Assignment 2
- **Main Technologies:** Flutter, Dart, Firebase, Riverpod

## Problem

ALU students often find internships and startup opportunities through informal channels such as WhatsApp groups and personal messages.

This makes opportunities difficult to search, save, verify, and manage.

Student-led startups also need a simple way to post opportunities and manage applicants.

ALU Hub brings these activities into one platform.

## Main Users

The application has three user roles:

### Student

Students can:

- Register using an official `@alustudent.com` email
- Sign in and sign out
- View active opportunities
- Search for opportunities
- View opportunity details
- Save and remove bookmarks
- Apply for opportunities
- Track application status
- Receive status-change notifications
- Edit their profile

### Startup

Startups can:

- Register using a valid account email
- Provide the founder's `@alustudent.com` email
- Complete a startup profile
- Wait for Admin verification
- Create opportunities after approval
- Edit opportunities
- Activate or deactivate opportunities
- Delete opportunities
- View applicants
- Update application status
- Manage their startup profile

### Admin

The Admin can:

- Sign in using an account created manually in Firebase
- View startup verification requests
- Review startup information
- Approve startup accounts
- Reject startup accounts with a reason
- Move startup accounts back to Pending
- Control which startups can post opportunities

## Main Features

- Firebase email and password authentication
- Role-based registration
- Student ALU email validation
- Startup founder ALU email validation
- Admin startup verification
- Role-based navigation
- Opportunity creation and management
- Opportunity search and filtering
- Bookmarking
- Application submission
- Duplicate application prevention
- Applicant management
- Application status tracking
- Real-time notifications
- Firestore Security Rules
- Riverpod state management
- Loading, empty, success, and error states

## Technology Stack

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Riverpod
- Material Design

## Project Architecture

The project uses a layered structure.

```text
Flutter Screens
      ↓
Riverpod Providers
      ↓
Repositories
      ↓
Firebase Authentication and Cloud Firestore