import 'package:flutter/material.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';

class PayPalView extends StatefulWidget {
  final double amount;
  final bool sandboxMode;
  final List<PayPalItem> items;
  final Function onSuccess;

  const PayPalView({
    super.key,
    required this.amount,
    required this.sandboxMode,
    required this.items,
    required this.onSuccess
  });

  @override
  State<PayPalView> createState() => _PayPalViewState();
}

class _PayPalViewState extends State<PayPalView> {
  @override
  Widget build(BuildContext context) {
    return PaypalCheckoutView(
      sandboxMode: true,
      clientId: "AbhIOM3GmHg85LItYm-WSiSaSfKYd-Dxqytdm030oZcZ-j1457ra_PprwYKpksUtHUMtXgYww51lxw7W",
      secretKey: "EJfI8lwZJ3Wfbt_VcdJbFNvP9wc9xQk_jqSShwPBSGkvBfV55-YbuwzcHmv-MX7oFCuCWkkTpDeCccIh",
      transactions: [
        {
          "amount": {
            "total": '${widget.amount}',
            "currency": "PHP",
            "details": {
              "subtotal": '${widget.amount}',
              "shipping": '0',
              "shipping_discount": 0
            }
          },
          "description": "The payment transaction description.",
          // "payment_options": {
          //   "allowed_payment_method":
          //       "INSTANT_FUNDING_SOURCE"
          // },
          "item_list": {
            "items": widget.items.map((e) => {
              "name": e.name,
              "quantity": e.quantity,
              "price": e.price,
              "currency": "PHP"
            }).toList(),

            // shipping address is not required though
            //   "shipping_address": {
            //     "recipient_name": "tharwat",
            //     "line1": "Alexandria",
            //     "line2": "",
            //     "city": "Alexandria",
            //     "country_code": "EG",
            //     "postal_code": "21505",
            //     "phone": "+00000000",
            //     "state": "Alexandria"
            //  },
          }
        }
      ],
      note: "Contact us for any questions on your order.",
      onSuccess: widget.onSuccess,
      onError: (error) {
        print("onError: $error");
        Navigator.pop(context);
      },
      onCancel: () {
        print('cancelled:');
      },
    );
  }
}

class PayPalItem {
  final String name;
  final double price;
  final int quantity;
  final String currency;

  PayPalItem({
    required this.name,
    required this.price,
    required this.quantity,
    required this.currency,
  });
}
