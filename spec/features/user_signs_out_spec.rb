# require 'spec_helper'

feature 'user can sign out' do
  scenario 'while being signed in' do
    user = build :user
    sign_up(user)
    sign_in(user)
    click_button 'Sign out'
    expect(page).to have_content('You are now signed out. Have a nice day!')
    expect(page).not_to have_content('Welcome, test@test.com')
  end
end
