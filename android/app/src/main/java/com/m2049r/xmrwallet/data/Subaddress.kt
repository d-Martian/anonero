/*
 * Copyright (c) 2018 m2049r
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.m2049r.xmrwallet.data

import lombok.EqualsAndHashCode
import lombok.RequiredArgsConstructor
import lombok.ToString
import java.util.regex.Pattern

@ToString
@EqualsAndHashCode
data class Subaddress(
    val accountIndex: Int, val addressIndex: Int, val address: String?,
    val label: String? = null
) : Comparable<Subaddress> {
    private var amount: Long = 0

    fun setAmount(amount: Long) {
        this.amount = amount
    }

    override fun compareTo(another: Subaddress): Int { // newer is <
        val compareAccountIndex = another.accountIndex - accountIndex
        return if (compareAccountIndex == 0) another.addressIndex - addressIndex else compareAccountIndex
    }

    val squashedAddress: String
        get() = address!!.substring(0, 8) + "…" + address.substring(address.length - 8)
    val displayLabel: String?
        get() = if (label!!.isEmpty() || DEFAULT_LABEL_FORMATTER.matcher(label).matches()) "#$addressIndex" else label

    companion object {
     public  val DEFAULT_LABEL_FORMATTER = Pattern.compile("^[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{2}:[0-9]{2}:[0-9]{2}$")
    }
}