module Examples
  module Radios
    def departments_data
      <<~DATA
        @departments = [
          OpenStruct.new(id: 1, name: 'Sales'),
          OpenStruct.new(id: 2, name: 'Marketing'),
          OpenStruct.new(id: 3, name: 'Finance')
        ]
      DATA
    end

    def lunch_options
      <<~DATA
        @lunch_options = [
          OpenStruct.new(id: 1, name: 'Salad', description: 'Lettuce, tomato and cucumber'),
          OpenStruct.new(id: 2, name: 'Jacket potato', description: 'With cheese and baked beans')
        ]
      DATA
    end


    def radio_field
      <<~SNIPPET
        = f.govuk_collection_radio_buttons :department_id,
          departments,
          :id,
          :name
      SNIPPET
    end

    def radio_field_with_legend_and_hint
      <<~SNIPPET
        = f.govuk_collection_radio_buttons :new_department_id,
          departments,
          :id,
          :name,
          legend: { text: 'Which department do you work for?' },
          hint_text: 'There should be a sign near your desk'
      SNIPPET
    end

    def radio_field_with_label_and_descriptions
      <<~SNIPPET
        = f.govuk_collection_radio_buttons :lunch_id,
          lunch_options,
          :id,
          :name,
          :description,
          legend: { text: 'What would you like for lunch?' }
      SNIPPET
    end

    def radio_field_with_conditional_content
      <<~SNIPPET
        = f.govuk_radio_buttons_fieldset(:old_department_id, legend: { size: 'm', text: 'Which department do you work in?' }) do
          = f.govuk_radio_button :old_department_id, 'it', label: { text: 'Information Technology' }
          = f.govuk_radio_button :old_department_id, 'marketing', label: { text: 'Marketing' }
          = f.govuk_radio_divider
          = f.govuk_radio_button :old_department_id, 'other', label: { text: 'Other' } do
            = f.govuk_text_field :old_department_description
      SNIPPET
    end
  end
end