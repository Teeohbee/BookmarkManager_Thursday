describe User do
  let!(:user) do
    User.create(email: 'test@test.com', password: 'secret1234',
                password_confirmation: 'secret1234')
  end

  it 'authenticates when given a valid email and password' do
    authenticated_user = User.authenticate(user.email, user.password)
    expect(authenticated_user).to eq user
  end

  it 'does not authenticate when given an invalid email / password combination' do
    expect(User.authenticate(user.email, 'not_the_password')).to be_nil
  end

end
