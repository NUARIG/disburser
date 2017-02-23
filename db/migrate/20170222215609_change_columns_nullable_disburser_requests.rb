class ChangeColumnsNullableDisburserRequests < ActiveRecord::Migration[5.0]
  def change
    change_column_null(:disburser_requests, :methods_justifications, true)
    change_column_null(:disburser_requests, :cohort_criteria, true)
    change_column_null(:disburser_requestss, :data_for_cohort, true)
  end
end