Feature: Manage accounts
  In order to manage its collaborators
  An administrative user
  wants to add, edit and rename their user accounts
  
  Background:
    Given the following accounts:
      | email                 | firstname | lastname         | password |
      | terry@lovethe88.com   | Terry     | Richardson       | Sekret   |
      | contact@lovethe88.com | The88     |                  | Sekret   |
    # Then dump_users
    And I am authenticated as "terry@lovethe88.com" with "Sekret"
  
  Scenario: Register new account
    Given I am on the new account page
    When I fill in the following:
      | First name            | Bob            |
      | Last name             | The Builder    |
      | Email                 | bob@yahoo.com  |
      | Password              | bob123456      |
      | Password Confirmation | bob123456      |
    And I press "Save User"
    Then I should see "Edit Bob The Builder"

  @wip
  Scenario: Delete account
    Given the following accounts:
      ||
      ||
      ||
      ||
      ||
    When I delete the 3rd account
    Then I should see the following accounts:
      ||
      ||
      ||
      ||
  @wip
  Scenario Outline: Creating a new account
      Given I am not authenticated
      When I go to register # define this path mapping in features/support/paths.rb, usually as '/users/sign_up'
      And I fill in "user_email" with "<email>"
      And I fill in "user_password" with "<password>"
      And I fill in "user_password_confirmation" with "<password>"
      And I press "Sign up"
      Then I should see "logged in as <email>" # your work!

      Examples:
        | email           | password   |
        | testing@man.net | secretpass |
        | foo@bar.com     | fr33z3     |

  @wip
  Scenario: Willing to edit my account
      Given I am a new, authenticated user # beyond this step, your work!
      When I want to edit my account
      Then I should see the account initialization form
      And I should see "Your account has not been initialized yet. Do it now!"
      # And more view checking stuff