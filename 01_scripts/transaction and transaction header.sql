

SELECT ac.Antavo_ID						as antavo_id
,      ac.contactid						as customer_id
,      cu.customer_number        
,      s.sale_transaction        
,      d.full_date_datetime				as date_time
,      case when l.location_code = '196' then 'US'
			when l.location_code = '199' then 'NZ'
			when l.location_code = '299' then 'AU'
			when l.location_code = '799' then 'UK'
			else c.country_code            
	   end as country_code
,      l.location_code           
,      l.location_name           
,      SUM(s.sale_qty)					as total_sale_qty
,      SUM(s.sale_amount_incl_gst)		as total_sale_amount_incl_gst
,	   SUM(s.discount_amount_incl_gst)	as total_discount_amount_incl_gst
,      s.sale_invoice
       
FROM       [dbo].[fact_sales_trans]				s		(nolock)
INNER JOIN [dbo].[dim_customer]					cu		(nolock) ON s.dim_customer_key = cu.dim_customer_key
LEFT  JOIN [dbo].[dim_country]					c		(nolock) ON s.dim_country_key = c.dim_country_key
INNER JOIN [dbo].[dim_location]					l		(nolock) ON s.dim_location_key = l.dim_location_key
INNER JOIN [dbo].[dim_date]						d		(nolock) ON s.dim_date_key = d.dim_date_key
INNER JOIN [mkt].[antavo_contact]				ac		(nolock) ON cu.customer_number = ac.new_summitclubmemberid
																	AND cu.source_system = 'Summit'
																	AND cu.row_current_customer = 'Y'
WHERE cu.dim_customer_key > 2
	   And s.dim_date_key >= CONVERT(varchar,DATEADD (d, -2, getutcdate()),112)
GROUP BY ac.Antavo_ID
,        ac.contactid
,        cu.customer_number
,        s.sale_transaction
,        d.full_date_datetime
,        case when l.location_code = '196' then 'US'
			when l.location_code = '199' then 'NZ'
			when l.location_code = '299' then 'AU'
			when l.location_code = '799' then 'UK'
			else c.country_code            
	     end  
,        l.location_code
,        l.location_name
,        s.sale_invoice
;

--TRANSACTION DATA
SELECT ac.Antavo_ID                             as antavo_id
,      CONCAT(s.sale_transaction,sale_line_key) as transaction_key
,      ac.contactid                             as customer_id
,      cu.customer_number                     
,      s.sale_transaction                     
,      d.full_date_datetime                     as date_time
,      case when l.location_code = '196' then 'US'
			when l.location_code = '199' then 'NZ'
			when l.location_code = '299' then 'AU'
			when l.location_code = '799' then 'UK'
			else c.country_code            
	   end										as country_code                         
,      l.location_code                        
,      l.location_name                        
,      case when l.location_code = '196' then 'United States Dollar'
			when l.location_code = '199' then 'New Zealand Dollar'
			when l.location_code = '299' then 'Australian Dollar'
			when l.location_code = '799' then 'Great British Pound'
			else c.currency            
	   end										as currency
,      ps.status_description                    as product_status
,      p.sku                                  
,      p.sku_description                      
,      p.style                                
,      p.item_group                           
,      p.product_group                         
,      s.sale_qty                             
,      s.sale_amount_incl_gst 
,	   s.discount_amount_incl_gst                
,      p.activity                             
,      p.business_area                        
,      p.[collection]                         
,      p.size                                 
,      p.gender                               
,      p.colour                               
,      p.brand                                
,      NULL                                     as 'productinfo1'
,      NULL                                     as 'productinfo2'
,      NULL                                     as 'productinfo3'
,      NULL                                     as 'productinfo4'
,      NULL                                     as 'productinfo5'
,      NULL                                     as 'voucherinfo1'
,      NULL                                     as 'voucherinfo2'
,      NULL                                     as 'voucherinfo3'

FROM       [dbo].[fact_sales_trans]   s
INNER JOIN [dbo].[dim_customer]       cu ON s.dim_customer_key = cu.dim_customer_key
LEFT JOIN  [dbo].[dim_country]        c  ON s.dim_country_key = c.dim_country_key
INNER JOIN [dbo].[dim_location]       l  ON s.dim_location_key = l.dim_location_key
INNER JOIN [dbo].[dim_date]           d  ON s.dim_date_key = d.dim_date_key
INNER JOIN [mkt].[antavo_contact]     ac ON cu.customer_number = ac.new_summitclubmemberid
                                AND cu.source_system = 'Summit'
                                AND cu.row_current_customer = 'Y'
INNER JOIN [dbo].[dim_product]        p  ON s.dim_product_key = p.dim_product_key and p.dim_product_key >= 3
INNER JOIN [dbo].[dim_product_status] ps ON s.dim_product_status_key = ps.dim_product_status_key
WHERE cu.dim_customer_key > 2
	And s.dim_date_key >= CONVERT(varchar,DATEADD (d, -2, getutcdate()),112)
;

