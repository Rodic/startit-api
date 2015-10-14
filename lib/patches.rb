module ActiveRecord
   module Validations

    # Adds helpful message to the errors hash if invalid foreign key has been passed
    #
    # Example:
    # p = Participation.create(user: current_user, event_id: 0)
    # p.errors[:event_id] # => [ 'is not present in table "events"' ]
    #
    # Note, it will caught only the first violation. So in case when two invalid
    # foreign keys are passed only one message will be added!

    def save(options={})
      if options[:validate] == false
        super
      else
        begin
          valid?(options[:context]) && super
        rescue ActiveRecord::InvalidForeignKey => e
          e.message.match /DETAIL:\s\sKey\s\((\w+)\)=\(\d+\)\s(.+)\./
          errors.add($1, $2)
          false
        end
      end
    end
  end
end
