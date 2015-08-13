feature 'User sign-up' do
  #strictly speaking, tests that check UI (ie. have_content) should be separate
  #from the tests that check what we have in the DB - because these are separate
  #concerns & we should only test one concern at a time

  scenario 'I can sign up as a new user' do
    expect{ sign_up }.to change(User, :count).by(1)
    expect(page).to have_content('Welcome, alice@example.com')
    expect(User.first.email).to eq('alice@example.com')
  end

  scenario 'when the passwords do not match' do
    expect{ sign_up(password_confirmation: 'wrong') }.not_to change(User, :count)
    expect(current_path).to eq('/users') #current_path is a Capybara helper
    expect(page).to have_content 'Password and confirmation do not match'
  end

  scenario 'when the user does not provide an email' do
    expect{ sign_up(email: '') }.not_to change(User, :count)
    expect(current_path).to eq('/users') #current_path is a Capybara helper
    expect(page).to have_content 'You must provide a valid email address'
  end

  def sign_up(email: 'alice@example.com',
              password: '1234567',
              password_confirmation: '1234567')
    visit 'users/new'
    expect(page.status_code).to eq(200)
    fill_in :email,   with: email
    fill_in :password, with: password
    fill_in :password_confirmation, with: password_confirmation
    click_button 'Sign up'
  end

end
