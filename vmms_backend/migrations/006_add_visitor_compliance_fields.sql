ALTER TABLE visitors
  ADD COLUMN gender character varying(20),
  ADD COLUMN work_order_no character varying(100),
  ADD COLUMN work_order_expiry date,
  ADD COLUMN police_verification_certificate_number character varying(100),
  ADD COLUMN pvc_expiry date;
