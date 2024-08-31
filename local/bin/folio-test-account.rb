#!/usr/bin/env ruby
# frozen_string_literal: true

credential = "test@test.test"

account_klass = if Object.const_defined?("Folio::Account")
  Folio::Account
elsif Object.const_defined?("Folio::User")
  Folio::User
end

if account_klass.where(email: credential).present?
  print "Folio::Account exists\n"
else
  role = if account_klass.column_names.include?("roles")
    { roles: ["superuser"] }
  elsif account_klass.column_names.include?("role")
    { role: "superuser" }
  else
    { confirmed_at: Time.current, superadmin: true }
  end

  account = account_klass.create!(email: credential, password:  credential,
                                  first_name: "test", last_name: "test",
                                  **role)

  print "Created Folio::Account\n"
end

# ===============================================================================
# Squared: {{{

if defined? Squared
  if AdminUser.where(email: credential).present?
    print "AdminUser exists\n"
  else
    AdminUser.create!(email: credential, password: credential,
                      first_name: "test", last_name: "test",
                      role: "superuser")

    print "Created AdminUser\n"
  end

  Zone.all.each do |zone|
    if User.where(email: credential, zone_id: zone.id).present?
      print "User exists\n"
    else
      User.create!(email: credential, password: credential,
                   first_name: "test", last_name: "test",
                   nickname: "superuser", zone: zone)

      print "Created User\n"
    end
  end
end

# }}}
# ===============================================================================

# ===============================================================================
# MMSpektrum: {{{

if defined? Mmspektrum
  if Folio::User.where(email: credential).present?
    print "Folio::User exists\n"
  else
    Folio::User.create!(email: credential, password: credential,
                        first_name: "test", last_name: "test")

    print "Created Folio::User\n"
  end
end

# }}}
# ===============================================================================

# ===============================================================================
# Redside: {{{

if defined? Redside
  if Folio::User.where(email: credential).present?
    print "Folio::User exists\n"
  else
    Folio::User.create!(email: credential, password: credential,
                        first_name: "test", last_name: "test")

    print "Created Folio::User\n"
  end
end

# }}}
# ===============================================================================

# ===============================================================================
# Infocz: {{{

if defined? Infocz
  if Infocz::User.where(email: credential).present?
    print "Infocz::User exists\n"
  else
    Infocz::User.create!(email: credential, password: credential,
                         first_name: "test", last_name: "test")

    print "Created Infocz::User\n"
  end
end

# }}}
# ===============================================================================

# ===============================================================================
# Acbcz: {{{

if defined? Acb
  if Acb::User.where(email: credential).blank?
    Acb::User.create!(email: credential,
                      password: credential,
                      first_name: "test",
                      last_name: "test",
                      confirmed_at: DateTime.current,
                      confirmation_sent_at: DateTime.current - 1.hour)

    print "Created Acb::User\n"
  else
    print "Acb::User exists\n"
  end
end

# }}}
# ===============================================================================

# ===============================================================================
# Notesvilla: {{{

if defined? Notesvilla
  if Notesvilla::User.where(email: credential).present?
    Notesvilla::User.where(email: credential).update(credits_non_withdrawable: 1000,
                                                     credits_withdrawable: 1000)
    print "Notesvilla::User exists\n"
  else
    Notesvilla::User.create!(email: credential, password: credential,
                             first_name: "test", last_name: "test", phone: "724999999",
                             credits_non_withdrawable: 1000, credits_withdrawable: 1000)

    print "Created Notesvilla::User\n"
  end
end

# }}}
# ===============================================================================

# ===============================================================================
# Nextpagemedia: {{{

if defined? Nextpagemedia
  if Folio::User.where(email: credential).present?
    print "Folio::User exists\n"
  else
    Folio::User.create!(email: credential, password: credential,
                        first_name: "test", last_name: "test", phone: "724999999",
                        confirmed_at: Time.now, confirmation_sent_at: 1.hour.ago, unconfirmed_email: false)

    print "Created Folio::User\n"
  end
end

# }}}
# ===============================================================================
