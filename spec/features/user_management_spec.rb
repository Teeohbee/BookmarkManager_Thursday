feature 'User sign-up' do
  #strictly speaking, tests that check UI (ie. have_content) should be separate
  #from the tests that check what we have in the DB - because these are separate
  #concerns & we should only test one concern at a time

  scenario 'I can sign up as a new user' do
    user = build(:user)
    expect{ sign_up(user) }.to change(User, :count).by(1)
    expect(page).to have_content('Welcome, alice@example.com')
    expect(User.first.email).to eq('alice@example.com')
  end

  scenario 'when the passwords do not match' do
    user = build(:user, password_confirmation: 'wrong')
    expect{ sign_up(user) }.not_to change(User, :count)
    expect(current_path).to eq('/users') #current_path is a Capybara helper
    expect(page).to have_content 'Password does not match the confirmation'
  end

  scenario 'when the user does not provide an email' do
    user = build(:user, email: '')
    expect{ sign_up(user) }.not_to change(User, :count)
    expect(current_path).to eq('/users') #current_path is a Capybara helper
    expect(page).to have_content 'Email must not be blank'
  end

  scenario 'I cannot sign up with an existing email' do
    user = create(:user)
    sign_up(user)
    expect { sign_up(user) }.not_to change(User, :count)
    expect(current_path).to eq('/users')
    expect(page).to have_content 'Email is already taken'
  end

  scenario 'user can sign in' do
    user = create :user
    sign_in(user)
    expect(page).to have_content "Welcome, #{user.email}"
  end

  def sign_up(user)
    visit 'users/new'
    expect(page.status_code).to eq(200)
    fill_in :email,   with: user.email
    fill_in :password, with: user.password
    fill_in :password_confirmation, with: user.password_confirmation
    click_button 'Sign up'
  end

  def sign_in(user)
    visit '/sessions/new'
    fill_in :email, with: user.email
    fill_in :password, with: user.password
    click_button 'Sign me in!'
  end

end
