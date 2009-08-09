# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_phd_session',
  :secret      => 'ed9754a29855ffb2bc8aed523e00b48f74d2e805b86ffcebb07a62db4c357db33022c10d16ee8b3e4d247597babb4548d106b132b34f5e4429ad56fbe8265af0'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
