FactoryGirl.define do
  factory :disburser_request do
    methods_justifications Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/files/methods_justificatons.docx')))
    title            'placeholder'
    investigator     'placeholder'
    irb_number       'placeholder'
    cohort_criteria  'placehoder'
    data_for_cohort  'placehoder'
  end
end