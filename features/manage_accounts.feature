Feature: Manage accounts
  In order to manage its collaborators
  An administrative user
  wants to add, edit and rename their user accounts
  
  Background:
    Given the following accounts:
      | email                   | first_name | last_name         | password |  admin  |
      | terry@lovethe88.com     | Terry      | Richardson        | ******** |  true   |
      | contact@lovethe88.com   | The88      |                   | ******** |  true   |
      | non_admin@lovethe88.com | normal     | user              | ******** |  false  |
      | deletable@lovethe88.com | deletable  | user              | ******** |  true   |
    And I am authenticated as "terry@lovethe88.com" with "********"

  Scenario: See the accounts list
    Given I am on the admin users page
    Then I should see "Terry"
    And  I should see "The88"
    And  I should see "normal"
    And  I should see "deletable"
  
  Scenario: Register a new account
    Given I am on the new account page
    When I fill in the following:
      | First Name            | Bob            |
      | Last Name             | The Builder    |
      | Email                 | bob@yahoo.com  |
      | Password              | bob123456      |
      | Password Confirmation | bob123456      |
    And I press "Save"
    Then I should see "Edit Bob The Builder"

  Scenario: Creating a new account requires being authenticated
    Given I am not authenticated
    When I go to the new account page
    Then I should be on the login page
    And I should see "You are not authorized to access this page."

  Scenario: Creating a new account requires being admin
    When I am authenticated as "non_admin@lovethe88.com" with "********"
    When I go to the new account page
    Then I should see "You are not authorized to access this page."

  Scenario: Delete an account with id > 3
    Given I am on deletable@lovethe88.com account page
    When I follow "Delete"
    Then I should see "Successfully removed!"

  Scenario: Cannot delete an account with id < 3
    Given I am on contact@lovethe88.com account page
    Then I should not see "Delete"
