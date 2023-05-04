{% macro conversion_rate_by_field(field) %}

select {{ field }}, count(distinct case when event_type = 'checkout' then session_id else null end)/count(distinct session_id) as conversion_rate
from {{ ref('fact_page_views') }}
{{ dbt_utils.group_by(1) }}

{% endmacro %}