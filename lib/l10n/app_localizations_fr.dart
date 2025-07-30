// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get welcomeBack => 'Bon Retour';

  @override
  String get signInToAccount => 'Connectez-vous à votre compte';

  @override
  String get email => 'Email';

  @override
  String get enterEmail => 'Entrez votre email';

  @override
  String get password => 'Mot de passe';

  @override
  String get enterPassword => 'Entrez votre mot de passe';

  @override
  String get signIn => 'Se Connecter';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get pleaseEnterEmail => 'Veuillez entrer votre email';

  @override
  String get pleaseEnterValidEmail => 'Veuillez entrer un email valide';

  @override
  String get pleaseEnterPassword => 'Veuillez entrer votre mot de passe';

  @override
  String get passwordMinLength => 'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get forgotPasswordTitle => 'Mot de passe oublié ?';

  @override
  String get enterEmailToReset => 'Entrez votre email pour réinitialiser votre mot de passe';

  @override
  String get resetPassword => 'Réinitialiser le mot de passe';

  @override
  String get backToLogin => 'Retour à la connexion';

  @override
  String get emailSent => 'Email envoyé !';

  @override
  String get emailSentMessage => 'Nous avons envoyé un lien de réinitialisation à votre adresse email. Veuillez vérifier votre boîte de réception et suivre les instructions.';

  @override
  String get language => 'Langue';

  @override
  String get english => 'Anglais';

  @override
  String get french => 'Français';

  @override
  String get welcomeToBusinessServices => 'Bienvenue aux Services d\'Entreprise';

  @override
  String get chooseServiceToStart => 'Choisissez un service pour commencer';

  @override
  String get parkACar => 'Garer une Voiture';

  @override
  String get sendBarrelsToGuinea => 'Expédition de Colis';

  @override
  String get transportCarsToGuinea => 'Transporter des Voitures en Guinée';

  @override
  String get sellCars => 'Vendre des Voitures';

  @override
  String get carParkingService => 'Service de Stationnement';

  @override
  String get enterCarDetailsToGenerateReceipt => 'Entrez les détails de la voiture pour générer un reçu';

  @override
  String get printReceipt => 'Imprimer le Reçu';

  @override
  String get name => 'Nom';

  @override
  String get make => 'Marque';

  @override
  String get model => 'Modèle';

  @override
  String get year => 'Année';

  @override
  String get vinNumber => 'Numéro VIN';

  @override
  String get parkingDate => 'Date de Stationnement';

  @override
  String get parkingDateTime => 'Date et Heure de Stationnement';

  @override
  String get selectDateTime => 'Sélectionner Date et Heure';

  @override
  String get receiptGenerated => 'Reçu généré et envoyé à l\'imprimante avec succès !';

  @override
  String errorGeneratingReceipt(Object error) {
    return 'Erreur lors de la génération du reçu : $error';
  }

  @override
  String get pleaseEnterOwnerName => 'Veuillez entrer le nom du propriétaire';

  @override
  String get pleaseEnterCarMake => 'Veuillez entrer la marque de la voiture';

  @override
  String get pleaseEnterCarModel => 'Veuillez entrer le modèle de la voiture';

  @override
  String get pleaseEnterCarYear => 'Veuillez entrer l\'année de la voiture';

  @override
  String get pleaseEnterVinNumber => 'Veuillez entrer le numéro VIN';

  @override
  String get done => 'Terminé';

  @override
  String get account => 'Compte';

  @override
  String get role => 'Rôle';

  @override
  String get logout => 'Déconnexion';

  @override
  String get signOutOfAccount => 'Se déconnecter de votre compte';

  @override
  String get customer => 'Client';

  @override
  String get staff => 'Personnel';

  @override
  String get barrelShippingService => 'Service d\'Expédition de Colis';

  @override
  String get enterShippingDetailsForGuinea => 'Entrez les détails d\'expédition et la destination';

  @override
  String get submit => 'Soumettre';

  @override
  String get senderName => 'Nom de l\'Expéditeur';

  @override
  String get address => 'Adresse';

  @override
  String get receiverName => 'Nom du Destinataire';

  @override
  String get receiverPhone => 'Téléphone du Destinataire';

  @override
  String get price => 'Prix';

  @override
  String get carTransportService => 'Service de Transport de Voitures';

  @override
  String get enterCarTransportDetailsForGuinea => 'Entrez les détails de transport de voiture et la destination';

  @override
  String get ownerName => 'Nom du Propriétaire';

  @override
  String get carMake => 'Marque de Voiture';

  @override
  String get carModel => 'Modèle de Voiture';

  @override
  String get carYear => 'Année de la Voiture';

  @override
  String get transportDate => 'Date de Transport';

  @override
  String get carSalesService => 'Service de Vente de Voitures';

  @override
  String get browseAvailableCarsForSale => 'Parcourir les voitures disponibles à la vente';

  @override
  String get searchCars => 'Rechercher des voitures...';

  @override
  String get chatWithSeller => 'Discuter avec le Vendeur';

  @override
  String get toyotaCamry => 'Toyota Camry';

  @override
  String get hondaAccord => 'Honda Accord';

  @override
  String get fordEscape => 'Ford Escape';

  @override
  String yearLabel(Object year) {
    return 'Année : $year';
  }

  @override
  String mileageLabel(Object mileage) {
    return 'Kilométrage : $mileage';
  }

  @override
  String get mileage => 'kilométrage';

  @override
  String get carDetails => 'Détails de la Voiture';

  @override
  String get contactSeller => 'Contacter le Vendeur';

  @override
  String get viewMorePhotos => 'Voir Plus de Photos';

  @override
  String get carDescription => 'Description de la Voiture';

  @override
  String get features => 'Caractéristiques';

  @override
  String get contactInfo => 'Informations de Contact';

  @override
  String get sendWhatsAppMessage => 'Envoyer un Message WhatsApp';

  @override
  String whatsAppMessage(Object carPrice, Object carTitle, Object carYear) {
    return 'Salut ! Je suis intéressé par la $carTitle ($carYear) pour $carPrice. Pouvez-vous fournir plus de détails ?';
  }

  @override
  String get noResultsFound => 'Aucun résultat trouvé';

  @override
  String get tryDifferentSearch => 'Essayez un terme de recherche différent';

  @override
  String get home => 'Accueil';

  @override
  String get settings => 'Paramètres';

  @override
  String get appInformation => 'Informations sur l\'Application';

  @override
  String get appVersion => 'Version de l\'Application';

  @override
  String get companyName => 'Nom de l\'Entreprise';

  @override
  String get contactUs => 'Nous Contacter';

  @override
  String get phoneNumber => 'Numéro de Téléphone';

  @override
  String get emailAddress => 'Adresse Email';

  @override
  String get about => 'À Propos';

  @override
  String get privacyPolicy => 'Politique de Confidentialité';

  @override
  String get termsOfService => 'Conditions d\'Utilisation';

  @override
  String get manageCars => 'Gérer les Voitures';

  @override
  String get totalCars => 'Total des Voitures';

  @override
  String get activeCars => 'Voitures Actives';

  @override
  String get inactiveCars => 'Voitures Inactives';

  @override
  String get active => 'Actif';

  @override
  String get inactive => 'Inactif';

  @override
  String get addNewCar => 'Ajouter une Nouvelle Voiture';

  @override
  String get carTitle => 'Titre de la Voiture';

  @override
  String get cancel => 'Annuler';

  @override
  String get add => 'Ajouter';

  @override
  String get editCar => 'Modifier la Voiture';

  @override
  String get save => 'Enregistrer';

  @override
  String get staffAccess => 'Accès Personnel';

  @override
  String get staffLogin => 'Connexion Personnel';

  @override
  String get accessStaffFeatures => 'Accéder aux fonctionnalités et outils de gestion du personnel';

  @override
  String get invalidCredentials => 'Email ou mot de passe invalide';

  @override
  String get backToCustomerHome => 'Retour à l\'Accueil Client';

  @override
  String get trackShipment => 'Suivre l\'Expédition';

  @override
  String get tracking => 'Suivi';

  @override
  String get userManagement => 'Gestion des Utilisateurs';

  @override
  String get setAsCustomer => 'Définir comme Client';

  @override
  String get setAsStaff => 'Définir comme Personnel';

  @override
  String get setAsAdmin => 'Définir comme Administrateur';

  @override
  String get addStaffMember => 'Ajouter Personnel';

  @override
  String get users => 'Utilisateurs';

  @override
  String get noUsersFound => 'Aucun utilisateur trouvé.';

  @override
  String get enterStaffEmail => 'Entrez l\'email du personnel';

  @override
  String get enterTemporaryPassword => 'Entrez le mot de passe temporaire';

  @override
  String userRoleUpdated(String newRole) {
    return 'Rôle utilisateur mis à jour vers $newRole';
  }

  @override
  String failedToUpdateUserRole(String error) {
    return 'Échec de la mise à jour du rôle utilisateur : $error';
  }

  @override
  String get staffMemberAddedSuccessfully => 'Membre du personnel ajouté avec succès !';

  @override
  String failedToAddStaffMember(String error) {
    return 'Échec de l\'ajout du membre du personnel : $error';
  }

  @override
  String get admin => 'Administrateur';

  @override
  String get changePassword => 'Changer Mot de Passe';

  @override
  String get currentPassword => 'Mot de Passe Actuel';

  @override
  String get newPassword => 'Nouveau Mot de Passe';

  @override
  String get confirmNewPassword => 'Confirmer le Nouveau Mot de Passe';

  @override
  String get enterCurrentPassword => 'Entrez votre mot de passe actuel';

  @override
  String get enterNewPassword => 'Entrez votre nouveau mot de passe';

  @override
  String get confirmNewPasswordField => 'Confirmez votre nouveau mot de passe';

  @override
  String get updatePassword => 'Mettre à Jour le Mot de Passe';

  @override
  String get passwordChanged => 'Mot de Passe Changé';

  @override
  String get passwordChangedSuccessfully => 'Votre mot de passe a été changé avec succès !';

  @override
  String get passwordsMustMatch => 'Les mots de passe doivent correspondre';

  @override
  String get newPasswordMinLength => 'Le nouveau mot de passe doit contenir au moins 6 caractères';

  @override
  String get passwordChangeRequired => 'Changement de Mot de Passe Requis';

  @override
  String get passwordChangeRequiredMessage => 'Pour des raisons de sécurité, vous devez changer votre mot de passe par défaut.';

  @override
  String get changePasswordNow => 'Changer Maintenant';

  @override
  String get skipForNow => 'Ignorer pour l\'instant';

  @override
  String get updateAccountPassword => 'Mettre à jour le mot de passe de votre compte';

  @override
  String get firstName => 'Prénom';

  @override
  String get lastName => 'Nom de Famille';

  @override
  String get enterFirstName => 'Entrez le prénom';

  @override
  String get enterLastName => 'Entrez le nom de famille';

  @override
  String get addStaffInfo => 'Le nouveau membre du personnel sera créé avec un mot de passe par défaut \"123456\". Il devra le changer lors de sa première connexion.';

  @override
  String get selectMake => 'Sélectionner la Marque';

  @override
  String get selectModel => 'Sélectionner le Modèle';

  @override
  String get selectYear => 'Sélectionner l\'Année';

  @override
  String get selectPriceRange => 'Sélectionner la Gamme de Prix';

  @override
  String get selectMileageRange => 'Sélectionner la Gamme de Kilométrage';

  @override
  String get description => 'Description';

  @override
  String get fuelType => 'Type de Carburant';

  @override
  String get transmission => 'Transmission';

  @override
  String get bodyType => 'Type de Carrosserie';

  @override
  String get condition => 'État';

  @override
  String get selectFuelType => 'Sélectionner le Type de Carburant';

  @override
  String get selectTransmission => 'Sélectionner la Transmission';

  @override
  String get selectBodyType => 'Sélectionner le Type de Carrosserie';

  @override
  String get selectCondition => 'Sélectionner l\'État';

  @override
  String get gasoline => 'Essence';

  @override
  String get diesel => 'Diesel';

  @override
  String get hybrid => 'Hybride';

  @override
  String get electric => 'Électrique';

  @override
  String get manual => 'Manuelle';

  @override
  String get automatic => 'Automatique';

  @override
  String get sedan => 'Berline';

  @override
  String get suv => 'SUV';

  @override
  String get hatchback => 'Hayon';

  @override
  String get coupe => 'Coupé';

  @override
  String get convertible => 'Cabriolet';

  @override
  String get pickup => 'Pick-up';

  @override
  String get wagon => 'Break';

  @override
  String get excellent => 'Excellent';

  @override
  String get good => 'Bon';

  @override
  String get fair => 'Correct';

  @override
  String get poor => 'Mauvais';

  @override
  String get pleaseEnterPhoneNumber => 'Veuillez entrer le numéro de téléphone';

  @override
  String get viewRecords => 'Voir les Enregistrements';

  @override
  String get parkingRecords => 'Enregistrements de Stationnement';

  @override
  String get packageRecords => 'Enregistrements de Colis';

  @override
  String get transportRecords => 'Enregistrements de Transport';

  @override
  String get salesRecords => 'Enregistrements de Ventes';

  @override
  String get manageParkingRecords => 'Gérer les Enregistrements de Stationnement';

  @override
  String get managePackageRecords => 'Gérer les Enregistrements de Colis';

  @override
  String get manageTransportRecords => 'Gérer les Enregistrements de Transport';

  @override
  String get manageSalesRecords => 'Gérer les Enregistrements de Ventes';

  @override
  String get editRecord => 'Modifier';

  @override
  String get deleteRecord => 'Supprimer';

  @override
  String get recordDeleted => 'Enregistrement supprimé avec succès';

  @override
  String get recordUpdated => 'Enregistrement mis à jour avec succès';

  @override
  String get confirmDelete => 'Êtes-vous sûr de vouloir supprimer cet enregistrement ?';

  @override
  String get deleteConfirmation => 'Confirmer Suppression';

  @override
  String get status => 'Statut';

  @override
  String get createdAt => 'Créé le';

  @override
  String get destination => 'Destination';

  @override
  String get packageType => 'Type de Colis';

  @override
  String get weight => 'Poids';

  @override
  String get dimensions => 'Dimensions';

  @override
  String get transportMethod => 'Méthode de Transport';

  @override
  String get pickupLocation => 'Lieu de Ramassage';

  @override
  String get deliveryLocation => 'Lieu de Livraison';

  @override
  String get estimatedDelivery => 'Livraison Estimée';

  @override
  String get markSold => 'Marquer Vendu';

  @override
  String get sold => 'Vendu';

  @override
  String get markCarAsSold => 'Marquer comme Vendue';

  @override
  String get customerName => 'Nom du Client';

  @override
  String get customerPhone => 'Téléphone du Client';

  @override
  String get salePrice => 'Prix de Vente';

  @override
  String get markAsSold => 'Marquer Vendu';

  @override
  String get pleaseEnterAllFields => 'Veuillez remplir tous les champs';

  @override
  String get carMarkedAsSoldSuccess => 'Voiture marquée comme vendue et enregistrement de vente créé !';

  @override
  String get errorMarkingCarAsSold => 'Erreur lors du marquage de la voiture comme vendue';

  @override
  String get packageRecordCreated => 'Enregistrement de colis créé avec succès !';

  @override
  String get updatePackageStatus => 'Changer Statut';

  @override
  String get updateTransportStatus => 'Changer Statut Transport';

  @override
  String get currentStatus => 'Statut Actuel';

  @override
  String get updateStatus => 'Mettre à Jour';

  @override
  String get statusUpdatedSuccessfully => 'Statut mis à jour avec succès !';

  @override
  String get contactStaffForUpdates => 'Contactez le personnel pour les mises à jour';
}
