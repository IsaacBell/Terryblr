Feature: Manage posts
  In order to animate its Terryblr
  An administrative user
  wants to add, edit and delete posts
  
  Background:
    Given the following accounts:
      | email                   | first_name | last_name         | password |  admin  |
      | terry@lovethe88.com     | Terry      | Richardson        | ******** |  true   |
    And I am authenticated as "terry@lovethe88.com" with "********"
    And the following posts:
      | title         |                   body                    | post_type   |    state    |
      | Hey guys      | Nevermind, just testing my new site.      | post        |  published  |
      | New expo      | Do not miss it !!!                        | post        |  published  |
      | My draft         | Not ready for prime time yet...           | post        |  drafted    |

  Scenario: List the posts
    Given I am on the posts admin page
    # Then show me the posts
    Then I should see "Hey guys"
    And  I should see "New expo"
    And  I should see "My draft"

  Scenario: Create a posts
    Given I am on the posts admin page
    And I follow "Post"
    When I fill in the following:
      | Title       | New event    |
      | Body        | Come join us !   |
    And I press "Save"
    Then I should see "New event"
    Then I should see "Your post is now live"
  
  Scenario: Delete a post
    Given I am on the posts admin page
    When I follow "New expo"
    Then I should see "Edit Post"
    When I follow "Delete"
    Then I should see "Successfully removed!"
    And I should see "Archives: 2 Posts"