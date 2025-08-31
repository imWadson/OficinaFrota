describe('Login Page', () => {
  beforeEach(() => {
    cy.visit('/login')
  })

  it('should display login form', () => {
    cy.get('h2').should('contain', 'Frota Gestor')
    cy.get('input[type="email"]').should('be.visible')
    cy.get('input[type="password"]').should('be.visible')
    cy.get('button[type="submit"]').should('contain', 'Entrar')
  })

  it('should show validation errors for empty fields', () => {
    cy.get('button[type="submit"]').click()
    
    cy.get('input[type="email"]').should('have.class', 'border-red-300')
    cy.get('input[type="password"]').should('have.class', 'border-red-300')
  })

  it('should show error for invalid email', () => {
    cy.get('input[type="email"]').type('invalid-email')
    cy.get('input[type="password"]').type('password123')
    cy.get('button[type="submit"]').click()
    
    // Should show validation error
    cy.get('input[type="email"]').should('have.class', 'border-red-300')
  })

  it('should handle login with valid credentials', () => {
    // Mock successful login
    cy.intercept('POST', '**/auth/v1/token?grant_type=password', {
      statusCode: 200,
      body: {
        access_token: 'fake-token',
        user: {
          id: '1',
          email: 'test@example.com'
        }
      }
    }).as('loginRequest')

    cy.get('input[type="email"]').type('test@example.com')
    cy.get('input[type="password"]').type('password123')
    cy.get('button[type="submit"]').click()

    cy.wait('@loginRequest')
    
    // Should redirect to dashboard
    cy.url().should('eq', Cypress.config().baseUrl + '/')
  })

  it('should handle login error', () => {
    // Mock failed login
    cy.intercept('POST', '**/auth/v1/token?grant_type=password', {
      statusCode: 400,
      body: {
        error: 'Invalid login credentials'
      }
    }).as('loginError')

    cy.get('input[type="email"]').type('wrong@example.com')
    cy.get('input[type="password"]').type('wrongpassword')
    cy.get('button[type="submit"]').click()

    cy.wait('@loginError')
    
    // Should show error message
    cy.get('.text-red-600').should('be.visible')
  })
})
