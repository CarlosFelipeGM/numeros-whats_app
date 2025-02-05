import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:numeros_whats_app/display/ui/input_personalizado.dart';
import 'package:numeros_whats_app/extensions/numero_de_telefono_extension.dart';
import 'package:numeros_whats_app/extensions/string_extension.dart';
import 'package:numeros_whats_app/models/numero_de_telefono.dart';
import 'package:uuid/uuid.dart';

class PaginaAgregarNumeros extends StatefulWidget {
  const PaginaAgregarNumeros({
    super.key,
    required this.alAgregar,
    required this.numerosDeTelefono,
  });

  final List<NumeroDeTelefono> numerosDeTelefono;
  final void Function(NumeroDeTelefono) alAgregar;

  @override
  State<PaginaAgregarNumeros> createState() => _PaginaAgregarNumerosState();
}

class _PaginaAgregarNumerosState extends State<PaginaAgregarNumeros> {
  final _idForm = GlobalKey<FormState>();
  final _maskNumero = MaskTextInputFormatter(mask: '(+51) ### ### ###');
  final _numeroTelefonoController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _mensajeInicialController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _idForm,
        child: Column(
          spacing: 8,
          children: [
            InputPersonalizado(
              label: 'Ingrese número de telefono',
              keyboardType: TextInputType.phone,
              inputFormatters: [_maskNumero],
              validator: (valor) => RequiredValidator(
                      errorText: 'El numero de teléfono es requerido')
                  .call(valor),
              controller: _numeroTelefonoController,
            ),
            InputPersonalizado(
              controller: _descripcionController,
              maxLength: 20,
              autocorrect: false,
              label: 'Descripción',
              validator: (valor) =>
                  RequiredValidator(errorText: 'La descripcion es requerida')
                      .call(valor),
            ),
            InputPersonalizado(
              label: 'Mensaje inicial',
              controller: _mensajeInicialController,
            ),
            ElevatedButton.icon(
              onPressed: () {
                _agregarNumero(
                  despuesDeAgregar: (numeroDeTelofono) {
                    numeroDeTelofono.abrirEnWhatsApp();
                  },
                );
              },
              icon: Icon(Icons.person_add),
              label: Text('Abrir en WA'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                _agregarNumero();
              },
              icon: Icon(Icons.save),
              label: Text('Guardar número'),
            ),
          ],
        ),
      ),
    );
  }

  void _agregarNumero({void Function(NumeroDeTelefono)? despuesDeAgregar}) {
    final esValido = _idForm.currentState?.validate() ?? false;
    if (esValido) {
      final numeroSinFormato = _maskNumero.getUnmaskedText();
      final numeroPlano = numeroSinFormato.cadenaConCodigoDePais();
      final numeroConFormato = _maskNumero.getMaskedText();
      final elNumeroExiste =
          widget.numerosDeTelefono.cast<NumeroDeTelefono?>().firstWhere(
        (numeroTelefono) {
          if (numeroTelefono?.numeroDeTelefonoPlano == numeroPlano) {
            return true;
          }

          return false;
        },
        orElse: () {
          return null;
        },
      );

      if (elNumeroExiste != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('El numero ya existe'),
          ),
        );
      } else {
        final id = Uuid().v1();
        final descripcion = _descripcionController.text;
        final mensajeInicial =
            _mensajeInicialController.text.replaceAll(' ', '%20');
        final numeroDeTelefono = NumeroDeTelefono(
            id: id,
            numeroDeTelefonoPlano: numeroPlano,
            numeroDeTelefonoFormateado: numeroConFormato,
            descripcion: descripcion,
            mensajeInicial: mensajeInicial);

        widget.alAgregar(numeroDeTelefono);

        despuesDeAgregar?.call(numeroDeTelefono);

        _numeroTelefonoController.clear();
        _descripcionController.clear();
        _mensajeInicialController.clear();
      }
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  void dispose() {
    _numeroTelefonoController.dispose();
    _descripcionController.dispose();
    _mensajeInicialController.dispose();
    super.dispose();
  }
}
