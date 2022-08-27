package com.m2049r.xmrwallet.data;//package xmr.anon_wallet.wallet.data;
//
//import androidx.annotation.NonNull;
//import androidx.annotation.Nullable;
//
//
//import anon.xmr.app.anon_wallet.R;
//import lombok.Getter;
//import lombok.RequiredArgsConstructor;
//
//@RequiredArgsConstructor
//public enum Crypto {
//    XMR("XMR", true, "monero:tx_amount:recipient_name:tx_description", R.id.class, R.drawable.ic_monero, R.drawable.ic_monero_bw, Wallet::isAddressValid),
//
//    @Getter
//    @NonNull
//    private final String symbol;
//    @Getter
//    private final boolean casefull;
//    @NonNull
//    private final String uriSpec;
//    @Getter
//    private final int buttonId;
//    @Getter
//    private final int iconEnabledId;
//    @Getter
//    private final int iconDisabledId;
//    @NonNull
//    private final Validator validator;
//
//    @Nullable
//    public static Crypto withScheme(@NonNull String scheme) {
//        for (Crypto crypto : values()) {
//            if (crypto.getUriScheme().equals(scheme)) return crypto;
//        }
//        return null;
//    }
//
//    @Nullable
//    public static Crypto withSymbol(@NonNull String symbol) {
//        final String upperSymbol = symbol.toUpperCase();
//        for (Crypto crypto : values()) {
//            if (crypto.symbol.equals(upperSymbol)) return crypto;
//        }
//        return null;
//    }
//
//    interface Validator {
//        boolean validate(String address);
//    }
//
//    // TODO maybe cache these segments
//    String getUriScheme() {
//        return uriSpec.split(":")[0];
//    }
//
//    String getUriAmount() {
//        return uriSpec.split(":")[1];
//    }
//
//    String getUriLabel() {
//        return uriSpec.split(":")[2];
//    }
//
//    String getUriMessage() {
//        return uriSpec.split(":")[3];
//    }
//
//    boolean validate(String address) {
//        return validator.validate(address);
//    }
//}
