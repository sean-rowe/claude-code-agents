# SOLID Agent

Enforces SOLID principles, Clean Code, and strict typing with full documentation.

## Usage
```
/solidAgent [analyze|refactor|implement] [file|directory]
```

## Core Principles Enforced

### SOLID Principles

#### Single Responsibility (SRP)
```typescript
// ❌ WRONG - Multiple responsibilities
class UserService {
  validateEmail(email: string): boolean { }
  hashPassword(password: string): string { }
  sendEmail(to: string, subject: string): void { }
  saveToDatabase(user: User): void { }
}

// ✅ CORRECT - Single responsibility per class
class EmailValidator {
  validate(email: string): boolean { }
}

class PasswordHasher {
  hash(password: string): string { }
}

class EmailService {
  send(to: string, subject: string): void { }
}

class UserRepository {
  save(user: User): void { }
}
```

#### Open/Closed Principle (OCP)
```typescript
// ❌ WRONG - Modifying existing code
class PaymentProcessor {
  process(type: string, amount: number): void {
    if (type === 'credit') { /* credit logic */ }
    else if (type === 'debit') { /* debit logic */ }
    // Adding new type requires modifying this class
  }
}

// ✅ CORRECT - Open for extension
interface PaymentMethod {
  process(amount: number): PaymentResult;
}

class CreditCardPayment implements PaymentMethod {
  process(amount: number): PaymentResult { }
}

class DebitCardPayment implements PaymentMethod {
  process(amount: number): PaymentResult { }
}
// New payment methods just implement interface
```

#### Liskov Substitution (LSP)
```typescript
// ❌ WRONG - Subtype changes behavior
class Rectangle {
  setWidth(w: number): void { this.width = w; }
  setHeight(h: number): void { this.height = h; }
}

class Square extends Rectangle {
  setWidth(w: number): void {
    this.width = w;
    this.height = w; // Violates LSP!
  }
}

// ✅ CORRECT - Subtypes maintain contracts
interface Shape {
  getArea(): number;
}

class Rectangle implements Shape {
  constructor(private width: number, private height: number) {}
  getArea(): number { return this.width * this.height; }
}

class Square implements Shape {
  constructor(private side: number) {}
  getArea(): number { return this.side * this.side; }
}
```

#### Interface Segregation (ISP)
```typescript
// ❌ WRONG - Fat interface
interface Worker {
  work(): void;
  eat(): void;
  sleep(): void;
}

// ✅ CORRECT - Segregated interfaces
interface Workable {
  work(): void;
}

interface Feedable {
  eat(): void;
}

interface Restable {
  sleep(): void;
}

class Human implements Workable, Feedable, Restable {
  work(): void { }
  eat(): void { }
  sleep(): void { }
}

class Robot implements Workable {
  work(): void { }
  // Robots don't eat or sleep
}
```

#### Dependency Inversion (DIP)
```typescript
// ❌ WRONG - Depends on concrete implementation
class EmailService {
  private smtp = new SMTPClient(); // Concrete dependency

  send(message: string): void {
    this.smtp.sendEmail(message);
  }
}

// ✅ CORRECT - Depends on abstraction
interface EmailClient {
  sendEmail(message: string): void;
}

class EmailService {
  constructor(private client: EmailClient) {} // Injected dependency

  send(message: string): void {
    this.client.sendEmail(message);
  }
}
```

### Clean Code Rules

#### Function Rules
- Maximum 20 lines
- Maximum 3 parameters
- Single purpose
- Descriptive names
- No side effects

#### Class Rules
- Maximum 200 lines
- Single responsibility
- High cohesion
- Low coupling

#### Documentation Requirements
```typescript
/**
 * Authenticates a user with the provided credentials.
 *
 * @param credentials - The user's login credentials
 * @param credentials.email - The user's email address (must be valid email format)
 * @param credentials.password - The user's password (min 8 chars, must include number)
 * @param options - Optional authentication configuration
 * @param options.rememberMe - Whether to create persistent session (default: false)
 * @param options.ipAddress - Client IP for rate limiting (default: extracted from request)
 *
 * @returns Promise resolving to authenticated user data with session token
 *
 * @throws {ValidationError} When email format is invalid
 * @throws {AuthenticationError} When credentials are incorrect
 * @throws {RateLimitError} When too many failed attempts from IP
 * @throws {AccountLockError} When account is locked due to security
 *
 * @example
 * ```typescript
 * try {
 *   const user = await authenticateUser(
 *     { email: 'user@example.com', password: 'SecurePass123!' },
 *     { rememberMe: true }
 *   );
 *   console.log(`Welcome ${user.name}`);
 * } catch (error) {
 *   if (error instanceof AuthenticationError) {
 *     console.error('Invalid credentials');
 *   }
 * }
 * ```
 *
 * @since 2.0.0
 * @see {@link User} for user data structure
 * @see {@link AuthenticationError} for error handling
 */
export async function authenticateUser(
  credentials: LoginCredentials,
  options?: AuthOptions
): Promise<AuthenticatedUser> {
  // Implementation
}
```

### Type Safety Rules

#### BANNED Generic Types
```typescript
// ❌ ALL BANNED
type Data = any;
type Result = unknown;
type Handler = Function;
type Config = Object;
type Dict = object;
type Callback = (...args: any[]) => any;

// ✅ CORRECT - Specific types
interface UserData {
  id: string;
  email: string;
  profile: UserProfile;
}

type AuthResult =
  | { success: true; user: User; token: string }
  | { success: false; error: AuthError };

type ClickHandler = (event: MouseEvent) => void;

interface AppConfig {
  apiUrl: string;
  timeout: number;
  retryAttempts: number;
}

type UserMap = Map<string, User>;

type AsyncCallback<T> = (error: Error | null, result?: T) => void;
```

#### Required Type Patterns
```typescript
// Every function must have typed parameters and return
function calculate(a: number, b: number): number { }

// Async functions must specify Promise type
async function fetchUser(id: string): Promise<User> { }

// Arrays must specify element type
const users: User[] = [];

// Objects must have interfaces
interface Config {
  url: string;
  port: number;
}

// Generics must have constraints
function getValue<T extends Record<string, unknown>>(
  obj: T,
  key: keyof T
): T[keyof T] { }
```

## Validation Checks

### Type Safety Validation
- [ ] Zero uses of 'any'
- [ ] Zero uses of 'unknown' (without type guards)
- [ ] Zero uses of 'Object' or 'object'
- [ ] Zero uses of 'Function'
- [ ] All parameters typed
- [ ] All returns typed
- [ ] All arrays have element types
- [ ] All promises have resolution types

### SOLID Validation
- [ ] Each class has single responsibility
- [ ] New features don't modify existing code
- [ ] Subtypes are substitutable
- [ ] No fat interfaces
- [ ] Dependencies on abstractions only

### Clean Code Validation
- [ ] Functions ≤ 20 lines
- [ ] Classes ≤ 200 lines
- [ ] Parameters ≤ 3
- [ ] Nesting ≤ 2 levels
- [ ] No duplicate code
- [ ] Descriptive names

### Documentation Validation
- [ ] All public methods documented
- [ ] All parameters have @param
- [ ] All returns have @returns
- [ ] All exceptions have @throws
- [ ] Complex methods have @example
- [ ] Types are fully described

## Agent Actions

1. **Analyze**: Check existing code for violations
2. **Refactor**: Fix violations while maintaining functionality
3. **Implement**: Write new code following all principles

## Report Format
```
=== SOLID & CLEAN CODE REPORT ===

SOLID Compliance:
- Single Responsibility: ✅ (12 classes checked)
- Open/Closed: ✅ (No modifications needed)
- Liskov Substitution: ✅ (All subtypes valid)
- Interface Segregation: ✅ (17 interfaces)
- Dependency Inversion: ✅ (All injected)

Clean Code Metrics:
- Longest function: 18 lines ✅
- Largest class: 145 lines ✅
- Max parameters: 3 ✅
- Max nesting: 2 ✅
- Duplication: 0% ✅

Type Safety:
- Uses of 'any': 0 ✅
- Uses of 'unknown': 0 ✅
- Uses of 'Object': 0 ✅
- Uses of 'Function': 0 ✅
- Untyped parameters: 0 ✅
- Untyped returns: 0 ✅

Documentation Coverage:
- Public methods: 100% ✅
- Parameters: 100% ✅
- Returns: 100% ✅
- Exceptions: 100% ✅
- Examples: 23/23 complex methods ✅

Issues Fixed:
1. UserService split into 4 classes (SRP)
2. PaymentProcessor refactored to strategy pattern (OCP)
3. Removed 'any' from 7 locations
4. Added documentation to 31 methods
5. Reduced processOrder() from 45 to 18 lines

Ready for Production: YES ✅
==================================
```

## Guarantee

This agent ensures:
- ZERO type safety violations
- FULL SOLID compliance
- CLEAN code throughout
- 100% documentation coverage
- Production-ready code