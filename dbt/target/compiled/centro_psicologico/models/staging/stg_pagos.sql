select
    pago_id,
    sesion_id,
    (DATE '1970-01-01' + fecha_pago) as fecha_pago,
    coalesce(monto, 0.00)           as monto,
    comprobante,
    metodo_pago,
    estado_pago
from "dm_centro_psicologico"."raw"."pagos"