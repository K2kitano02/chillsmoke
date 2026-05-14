# frozen_string_literal: true

module Purchase
  class Create
    Error = Class.new(StandardError)
    AlreadyPurchased = Class.new(Error)
    InsufficientBalance = Class.new(Error)

    def self.call(user:, wishlist:)
      new(user: user, wishlist: wishlist).call
    end

    def initialize(user:, wishlist:)
      @user = user
      @wishlist = wishlist
    end

    def call
      ActiveRecord::Base.transaction do
        user.lock!
        wishlist.lock!
        wishlist.reload

        raise AlreadyPurchased if wishlist.is_purchased?

        balance = Money::BalanceQuery.call(user)
        raise InsufficientBalance if balance.usable_yen < wishlist.price

        wishlist.create_user_purchase_history!(amount: wishlist.price, purchased_at: Time.current)
        wishlist.update!(is_purchased: true)
      end

      wishlist
    rescue ActiveRecord::RecordNotUnique
      raise AlreadyPurchased
    end

    private

    attr_reader :user, :wishlist
  end
end
