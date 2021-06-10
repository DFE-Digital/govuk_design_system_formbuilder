describe GOVUKDesignSystemFormBuilder::FormBuilder do
  include_context 'setup builder'

  describe '#date_input_group' do
    let(:method) { :govuk_date_field }
    let(:attribute) { :born_on }

    let(:fieldset_heading) { 'Date of birth' }
    let(:legend_text) { 'When were you born?' }
    let(:hint_text) { 'It says it on your birth certificate' }

    let(:day_multiparam_attribute) { '3i' }
    let(:month_multiparam_attribute) { '2i' }
    let(:year_multiparam_attribute) { '1i' }
    let(:multiparam_attributes) { [day_multiparam_attribute, month_multiparam_attribute, year_multiparam_attribute] }

    let(:day_identifier) { "person-born-on-#{day_multiparam_attribute}-field" }
    let(:month_identifier) { "person-born-on-#{month_multiparam_attribute}-field" }
    let(:year_identifier) { "person-born-on-#{year_multiparam_attribute}-field" }

    let(:args) { [method, attribute] }
    subject { builder.send(*args) }

    let(:field_type) { 'input' }
    let(:aria_described_by_target) { 'fieldset' }

    include_examples 'HTML formatting checks'

    it_behaves_like 'a field that supports hints'

    it_behaves_like 'a field that supports errors' do
      let(:object) { Person.new(born_on: Date.today.next_year(5)) }

      let(:error_message) { /Your date of birth must be in the past/ }
      let(:error_class) { 'govuk-input--error' }
      let(:error_identifier) { 'person-born-on-error' }
    end

    it_behaves_like 'a field that accepts arbitrary blocks of HTML' do
      let(:described_element) { 'fieldset' }

      # the block content (p) should be between the hint (span) and the input container (div)
      context 'ordering' do
        let(:hint_span_selector) { 'span.govuk-hint' }
        let(:block_paragraph_selector) { 'p.block-content' }
        let(:govuk_date_selector) { 'div.govuk-date-input' }

        let(:paragraph) { 'A descriptive paragraph all about dates' }

        subject do
          builder.send(*args, legend: { text: legend_text }, hint: { text: hint_text }) do
            builder.tag.p(paragraph, class: 'block-content')
          end
        end

        specify 'the block content should be between the hint and the date inputs' do
          expect(
            parsed_subject.css([hint_span_selector, block_paragraph_selector, govuk_date_selector].join(',')).map(&:name)
          ).to eql(%w(p span div))
        end
      end
    end

    it_behaves_like 'a field that supports setting the legend via localisation'
    it_behaves_like 'a field that supports setting the legend caption via localisation'
    it_behaves_like 'a field that supports setting the hint via localisation'

    it_behaves_like 'a field that supports custom branding'
    it_behaves_like 'a field that contains a customisable form group'

    it_behaves_like 'a field that supports a fieldset with legend'
    it_behaves_like 'a field that supports captions on the legend'

    it_behaves_like 'a date field that accepts a plain ruby object' do
      let(:described_element) { ['input', { count: 3 }] }
    end

    specify 'should output a form group with fieldset, date group and 3 inputs and labels' do
      expect(subject).to have_tag('div', with: { class: 'govuk-form-group' }) do |fg|
        expect(fg).to have_tag('fieldset', with: { class: 'govuk-fieldset' }) do |fs|
          expect(fs).to have_tag('div', with: { class: 'govuk-date-input' }) do |di|
            expect(di).to have_tag('input', with: { type: 'text' }, count: 3)
            expect(di).to have_tag('label', count: 3)
          end
        end
      end
    end

    context 'separate date part inputs' do
      specify 'inputs should have the correct labels' do
        expect(subject).to have_tag('div', with: { class: 'govuk-date-input' }) do |di|
          %w(Day Month Year).each do |label_text|
            expect(di).to have_tag('label', text: label_text)
          end
        end
      end

      specify 'inputs should have the correct name' do
        multiparam_attributes.each do |mpa|
          expect(subject).to have_tag('input', with: { name: "#{object_name}[#{attribute}(#{mpa})]" })
        end
      end

      context 'input attributes' do
        specify 'inputs should have a pattern that restricts entries to numbers' do
          expect(subject).to have_tag('input', with: { pattern: '[0-9]*' })
        end

        specify 'inputs should have an inputmode of numeric' do
          expect(subject).to have_tag('input', with: { inputmode: 'numeric' })
        end
      end

      specify 'labels should be associated with inputs' do
        [day_identifier, month_identifier, year_identifier].each do |identifier|
          expect(subject).to have_tag('label', with: { for: identifier }, count: 1)
          expect(subject).to have_tag('input', with: { id: identifier }, count: 1)
        end
      end

      specify 'inputs should have the correct classes' do
        expect(subject).to have_tag(
          'input',
          count: 3,
          with: { class: %w(govuk-input govuk-date-input__input) }
        )
      end

      specify 'inputs should have the width class' do
        expect(subject).to have_tag(
          'input',
          count: 2,
          with: { class: %w(govuk-input--width-2) }
        )

        expect(subject).to have_tag(
          'input',
          count: 1,
          with: { class: %w(govuk-input--width-4) }
        )
      end
    end

    context 'showing only month and year inputs' do
      subject { builder.send(*args, omit_day: true) }

      specify 'there should only be month and year inputs' do
        expect(subject).to have_tag('input', count: 2)

        [month_multiparam_attribute, year_multiparam_attribute].each do |mpa|
          expect(subject).to have_tag('input', with: { name: "#{object_name}[#{attribute}(#{mpa})]" })
        end
      end

      specify 'there be no day label' do
        expect(subject).not_to have_tag('label', text: 'Day')
      end

      specify 'there should only be month and year labels' do
        expect(subject).to have_tag('label', text: 'Month')
        expect(subject).to have_tag('label', text: 'Year')
      end
    end

    context 'default values' do
      let(:birth_day) { 3 }
      let(:birth_month) { 2 }
      let(:birth_year) { 1970 }

      context "when the attribute is a `Date` object" do
        let(:object) do
          Person.new(
            name: 'Joey',
            born_on: Date.new(birth_year, birth_month, birth_day)
          )
        end

        specify 'should set the day value correctly' do
          expect(subject).to have_tag('input', with: {
            id: day_identifier,
            value: birth_day
          })
        end

        specify 'should set the month value correctly' do
          expect(subject).to have_tag('input', with: {
            id: month_identifier,
            value: birth_month
          })
        end

        specify 'should set the year value correctly' do
          expect(subject).to have_tag('input', with: {
            id: year_identifier,
            value: birth_year
          })
        end
      end

      context "when the attribute is a multiparameter hash object" do
        let(:object) do
          Person.new(
            name: 'Joey',
            born_on: { 3 => birth_day, 2 => birth_month, 1 => birth_year }
          )
        end

        specify 'should set the day value correctly' do
          expect(subject).to have_tag('input', with: {
            id: day_identifier,
            value: birth_day
          })
        end

        specify 'should set the month value correctly' do
          expect(subject).to have_tag('input', with: {
            id: month_identifier,
            value: birth_month
          })
        end

        specify 'should set the year value correctly' do
          expect(subject).to have_tag('input', with: {
            id: year_identifier,
            value: birth_year
          })
        end
      end
    end

    context 'auto-completion' do
      context 'date of birth' do
        subject { builder.send(*args, date_of_birth: true) }
        specify "day field should have autocomplete attribute with value 'bday-day'" do
          expect(subject).to have_tag('input', with: { autocomplete: 'bday-day' })
        end

        specify "month field should have autocomplete attribute with value 'bday-month'" do
          expect(subject).to have_tag('input', with: { autocomplete: 'bday-month' })
        end

        specify "year field should have autocomplete attribute with value 'bday-year'" do
          expect(subject).to have_tag('input', with: { autocomplete: 'bday-year' })
        end
      end
    end

    describe "wildcards" do
      subject { builder.send(*args, wildcards: true) }

      specify %(the date and month input patterns contain an X) do
        expect(subject).to have_tag('input', with: { id: day_identifier, pattern: "[0-9X]*" })
        expect(subject).to have_tag('input', with: { id: month_identifier, pattern: "[0-9X]*" })
      end

      specify %(the year pattern doesn't contain an X) do
        expect(subject).to have_tag('input', with: { id: year_identifier, pattern: "[0-9]*" })
      end
    end

    describe "additional attributes" do
      subject { builder.send(*args, data: { test: "abc" }) }

      specify "should have additional attributes" do
        expect(subject).to have_tag('div', with: { 'data-test': 'abc' })
      end
    end

    describe "invalid date-like objects" do
      let(:wrong_date) { WrongDate.new(nil, nil, nil) }
      before { object.born_on = wrong_date }

      specify "fails with an appropriate error message" do
        expect { subject }.to raise_error(ArgumentError, /invalid Date-like object/)
      end
    end

    describe "hashes without the right keys" do
      let(:wrong_hash) { { d: 20, m: 3, y: 2009 } }
      before { object.born_on = wrong_hash }
      before { allow(Rails).to receive_message_chain(:logger, :warn) }
      before { subject }

      specify "logs an appropriate warning" do
        expect(Rails.logger).to have_received(:warn).with(/No key '.*' found in MULTIPARAMETER_KEY hash/).exactly(wrong_hash.length).times
      end

      specify "doesn't generate inputs with values" do
        parsed_subject.css('input').each do |element|
          expect(element.attributes.keys).not_to include('value')
        end
      end
    end
  end
end
