Feature: Require Labels

Scenario: owner
    Given I have resource that supports labels defined
    When it has labels
    Then it must have labels
    Then it must contain owner
	And its value must match the "^(vinsonr)$" regex

Scenario: application
    Given I have resource that supports labels defined
    When it has labels
    Then it must have labels
    Then it must contain application
	And its value must match the "^(web|app)$" regex

Scenario: version
    Given I have resource that supports labels defined
    When it has labels
    Then it must have labels
    Then it must contain version
	And its value must match the "^[0-9]\.[0-9]\.[0-9]$" regex

Scenario: environment
    Given I have resource that supports labels defined
    When it has labels
    Then it must have labels
    Then it must contain environment
	And its value must match the "^(dev|test|prod)$" regex

