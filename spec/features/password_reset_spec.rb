feature 'Password reset' do

 scenario 'requesting a password reset' do
   user = create :user
   sign_up(user)
   visit '/users/password_reset'
   fill_in 'email', with: user.email
   click_button 'Reset password'
   user = User.first(email: user.email)
   expect(user.password_token).not_to be_nil
   expect(page).to have_content 'Please check your emails'
 end
end
