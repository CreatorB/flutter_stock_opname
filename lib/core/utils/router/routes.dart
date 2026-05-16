enum Routes {
  initial('/'),
  navigation('/navigation'),
  login('/login'),
  register('/register'),
  verify('/verify'),
  profile('/profile'),
  settings('/settings'),
  update_password('/update_password'),
  sale('/sale'),
  cart('/cart'),
  payment_method('/payment_method'),
  cash_payment('/cash_payment'),
  edc_payment('/edc_payment'),
  receipt('/receipt'),
  opname('/opname'),
  ;

  final String path;
  const Routes(this.path);
}
