Feature: Manage accounts
  In order to manage its collaborators
  An administrative user
  wants to add, edit and rename their user accounts
  
  Background:
    Given the following accounts:
      | email                   | first_name | last_name         | password |  admin  |
      | terry@lovethe88.com     | Terry      | Richardson        | ******** |  true   |
      | contact@lovethe88.com   | The88      |                   | ******** |  true   |
      | non_admin@lovethe88.com | normal     | user              | ******** |  false   |
    And I am authenticated as "terry@lovethe88.com" with "********"
  
  Scenario: Register a new account
    Given I am on the new account page
    When I am on the new account page
    When I fill in the following:
      | First name            | Bob            |
      | Last name             | The Builder    |
      | Email                 | bob@yahoo.com  |
      | Password              | bob123456      |
      | Password Confirmation | bob123456      |
    And I press "Save User"
    Then I should see "Edit Bob The Builder"

  Scenario: Creating a new account requires admin rights
    Given I am not authenticated
    When I go to the new account page
    Then I should be on the homepage
    And I should see "You are not authorized to access this page."
    When I am authenticated as "non_admin@lovethe88.com" with "********"
    When I go to the new account page
    Then I should be on the homepage
    And I should see "You are not authorized to access this page."

