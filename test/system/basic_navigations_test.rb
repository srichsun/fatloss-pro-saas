require "application_system_test_case"

class BasicNavigationsTest < ApplicationSystemTestCase
  test "guest visiting root is prompted to sign in" do
    visit root_path

    assert_current_path login_path
    assert_selector "h2", text: "Sign in to your Coach Space"
  end

  test "coach can sign in and lands on their tenant space" do
    coach = users(:coach_one)

    visit login_path
    fill_in "Email", with: coach.email
    fill_in "Password", with: "password"
    click_on "Sign in"

    assert_text "Welcome to #{coach.tenant.name}"
    assert_current_path tenant_path(coach.tenant)
  end
end
