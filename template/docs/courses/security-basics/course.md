---
name: Security Basics
description: OWASP top 10, secrets management, input validation, and authentication patterns
difficulty: intermediate
estimated_sessions: 3-4
prerequisites: [claude-code-basics]
---

# Security Basics

Learn to identify and prevent the most common security vulnerabilities in web applications. Uses your actual project code for hands-on exercises.

## Module 1: The OWASP Top 10

### Concept: What Are the Most Common Vulnerabilities?

The OWASP Top 10 is the industry standard list of the most critical web application security risks. These aren't theoretical — they're the actual vulnerabilities that get exploited in real applications every day.

**Predict:** What do you think is the #1 most common web security vulnerability? (Hint: it's been in the top 3 for over a decade)

**Reveal:** Injection attacks (SQL injection, command injection, etc.) have consistently been among the top vulnerabilities. The current OWASP Top 10 (2021) lists:
1. Broken Access Control
2. Cryptographic Failures
3. Injection
4. Insecure Design
5. Security Misconfiguration
6. Vulnerable Components
7. Authentication Failures
8. Data Integrity Failures
9. Logging Failures
10. Server-Side Request Forgery

### Concept: Injection Attacks

An injection attack happens when untrusted data is sent to an interpreter as part of a command or query.

**Predict:** Look at this code. What's wrong with it?
```javascript
const query = `SELECT * FROM users WHERE name = '${userInput}'`;
db.execute(query);
```

**Reveal:** This is a classic SQL injection vulnerability. If `userInput` is `'; DROP TABLE users; --`, the query becomes:
```sql
SELECT * FROM users WHERE name = ''; DROP TABLE users; --'
```
The fix is parameterized queries:
```javascript
db.execute('SELECT * FROM users WHERE name = ?', [userInput]);
```

### Exercise: Find Injection Risks

Search your project for string concatenation in database queries, shell commands, or template strings that include user input. Run:
```
/security-check
```
Check the INJ-01 through INJ-05 findings.

## Module 2: Secrets Management

### Concept: What Counts as a Secret?

**Predict:** Which of these should NEVER appear in source code?
1. API keys
2. Database URLs
3. Port numbers
4. JWT signing secrets
5. Error messages

**Reveal:** 1, 2, and 4 are secrets. Port numbers and error messages are generally not sensitive (though error messages shouldn't leak internal details). Secrets belong in environment variables (`.env` files), not in code.

### Concept: The .env Pattern

Environment variables separate configuration from code. Different environments (development, staging, production) use different values without changing code.

**Predict:** Why does Big Gulps block Claude from editing `.env` files?

**Reveal:** AI assistants process and may retain context from files they read. `.env` files contain credentials — if they appear in conversation history, they could be exposed. The blocking hook prevents accidental secret exposure.

### Exercise: Audit Your Secrets

1. Check if `.env` is in `.gitignore`
2. Search for hardcoded strings that look like API keys: `grep -r "sk-\|api_key\|secret\|password" --include="*.ts" --include="*.js" src/`
3. Verify all secrets are referenced via `process.env.*` or equivalent

## Module 3: Input Validation

### Concept: Trust Boundaries

**Predict:** Where should you validate user input — at the UI layer, the API layer, or the database layer?

**Reveal:** At EVERY trust boundary. The UI provides good UX feedback, but it can be bypassed. The API layer is critical because it's the server's trust boundary. Database constraints are the last line of defense.

### Concept: Validation Strategies

```typescript
// Schema validation (recommended)
const UserSchema = z.object({
  name: z.string().min(1).max(100),
  email: z.string().email(),
  age: z.number().int().positive().max(150)
});

// Use at system boundaries
const result = UserSchema.safeParse(userInput);
if (!result.success) {
  // Handle validation error - don't expose internal details
  return { error: "Invalid input" };
}
```

**Predict:** Why use `.safeParse()` instead of `.parse()`?

**Reveal:** `.parse()` throws an exception on invalid input, which could crash your server if uncaught. `.safeParse()` returns a result object with `success: boolean` and either `data` or `error`, giving you control over error handling.

### Exercise: Check Your Validation

1. Find all API routes or form handlers in your project
2. Check if each one validates input before processing
3. Look for direct use of `req.body` or form data without validation

## Module 4: Authentication & Authorization

### Concept: Authentication vs Authorization

**Predict:** What's the difference between authentication and authorization?

**Reveal:**
- **Authentication** = "Who are you?" (login, identity verification)
- **Authorization** = "What can you do?" (permissions, roles, access control)

A user can be authenticated (logged in) but not authorized (lacks permission for a specific action).

### Concept: Common Auth Mistakes

**Predict:** Which of these is a security risk?
1. Storing passwords in plain text
2. Using JWT tokens that never expire
3. Checking authentication but not authorization on API routes
4. All of the above

**Reveal:** All of the above. Passwords must be hashed (bcrypt, argon2). JWTs need expiration times. Every API route needs BOTH authentication AND authorization checks.

### Exercise: Auth Audit

Run `/security-check` and review the AUTH and ACL findings. Check:
1. Are all API routes protected?
2. Do database queries scope to the authenticated user?
3. Are there any endpoints accessible without login that shouldn't be?

## Module 5: Secure Development Habits

### Concept: Security as a Habit

Security isn't a one-time audit — it's a daily practice. The hooks installed by Big Gulps automate the basics:
- `.env blocker` prevents accidental secret exposure
- Console sentinel catches data leaks in logs
- `/security-check` provides comprehensive auditing

### Concept: Defense in Depth

**Predict:** If you have input validation on your API, do you still need database constraints?

**Reveal:** Yes! Defense in depth means multiple layers of security. If one layer fails (bug in validation logic), the next layer catches it (database rejects invalid data). Never rely on a single security control.

### Exercise: Build Your Security Checklist

Create a checklist for your project:
- [ ] Secrets in .env, not in code
- [ ] .env in .gitignore
- [ ] Input validated at API boundaries
- [ ] Auth checks on all protected routes
- [ ] No sensitive data in logs
- [ ] Dependencies audited for vulnerabilities
- [ ] Error messages don't leak internals
