# Saropa Dart Utils

<!-- markdownlint-disable MD033 - Disable No HTML -->
<!-- <div style="background-color: #5266A8; padding: 1em; width: 35%; border-radius: 0.1em 0.1em 1.5em 0.1em;  box-shadow: 0.1em 0.1em 0.13em rgba(68, 68, 68, 0.35);">
  <img src="https://cdn.app.saropa.com/scripts/_default/image/logo/SaropaLogo2019_white2_minified.svg" alt="saropa company logo"  />
</div> -->
[![Saropa Logo](SaropaLogo2019_contrast-1200.png)](https://saropa.com)
<br>

Useful primitive tools 🚀 and extension methods 🤖 by [Saropa][saropa_link] 🎈

[![pub package](https://img.shields.io/pub/v/saropa_dart_utils.svg)](https://pub.dev/packages/saropa_dart_utils) [![license: very good analysis](https://img.shields.io/badge/license-GPL-purple.svg)](https://opensource.org/licenses/GPL) [![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

## Contents

- [Useful Methods](#useful-methods-or-extensions-you-will-ever-need)
- [Extensions](#extensions)
  - [String Extensions](#string-extensions)


## Useful methods or extensions you will ever need
```dart

String text = 'www.saropa.com';
print(text.removeStart('www.')); // Output: saropa.com

String? text;
print(text.isNullOrEmpty); // Output: true

text = "";
print(text.isNullOrEmpty); // Output: true

text = "Hello";
print(text.isNullOrEmpty); // Output: false


String? text;
print(text.notNullOrEmpty); // Output: false

text = "";
print(text.notNullOrEmpty); // Output: false

text = "Hello";
print(text.notNullOrEmpty); // Output: true

String? text = "Saropa";
print(text.encloseInParentheses()); // Output: (Saropa)

text = "";
print(text.encloseInParentheses(wrapEmpty: true)); // Output: ()

text = null;
print(text.encloseInParentheses()); // Output: null


String? text = "Saropa";
print(text.wrapWith(before: "(", after: ")")); // Output: (Saropa)
print(text.wrapWith(before: "Prefix-")); // Output: Prefix-Saropa
print(text.wrapWith(after: "-Suffix")); // Output: Saropa-Suffix

String text = "  Saropa   has   multiple   spaces  ";
print(text.removeConsecutiveSpaces()); // Output: "Saropa has multiple spaces"
print(text.removeConsecutiveSpaces(trim: false)); // Output: " Saropa has multiple spaces "

String text = "  Saropa   has   multiple   spaces  ";
print(text.compressSpaces()); // Output: "Saropa has multiple spaces"
print(text.compressSpaces(trim: false)); // Output: " Saropa has multiple spaces "

```

# Extensions
## String Extensions
```dart

String text = 'www.saropa.com';
print(text.removeStart('www.')); // Output: saropa.com

String? text;
print(text.isNullOrEmpty); // Output: true

text = "";
print(text.isNullOrEmpty); // Output: true

text = "Hello";
print(text.isNullOrEmpty); // Output: false


String? text;
print(text.notNullOrEmpty); // Output: false

text = "";
print(text.notNullOrEmpty); // Output: false

text = "Hello";
print(text.notNullOrEmpty); // Output: true

String? text = "Saropa";
print(text.encloseInParentheses()); // Output: (Saropa)

text = "";
print(text.encloseInParentheses(wrapEmpty: true)); // Output: ()

text = null;
print(text.encloseInParentheses()); // Output: null


String? text = "Saropa";
print(text.wrapWith(before: "(", after: ")")); // Output: (Saropa)
print(text.wrapWith(before: "Prefix-")); // Output: Prefix-Saropa
print(text.wrapWith(after: "-Suffix")); // Output: Saropa-Suffix

String text = "  Saropa   has   multiple   spaces  ";
print(text.removeConsecutiveSpaces()); // Output: "Saropa has multiple spaces"
print(text.removeConsecutiveSpaces(trim: false)); // Output: " Saropa has multiple spaces "

String text = "  Saropa   has   multiple   spaces  ";
print(text.compressSpaces()); // Output: "Saropa has multiple spaces"
print(text.compressSpaces(trim: false)); // Output: " Saropa has multiple spaces "


```


## Deployment Guide For Developers

1.⁠ ⁠Update [CHANGELOG.md](CHANGELOG.md)

2.⁠ ⁠Test ⁠ flutter test ⁠

3.⁠ ⁠Execute ⁠ dart doc ⁠

4.⁠ ⁠Deploy ⁠ dart pub publish ⁠

<br>
<p align="center">🌐 📖 👥 🏢 🚨 🔒 🤝 🎯 🛡️  📉 🆘 ⏱️ 🚑 📞 🌍 🔄 📲 💼</p>

## About Saropa

Saropa®️ is a technology company established in 2010. We have a strong background in financial services, online security and secure web communications.

Our team has extensive experience in top-tier financial technology and we are passionate believers in personal risk management. We are engaged and excited about our vision for family security and this encourages our culture of innovation.

Saropa Contacts is a private, cloud-connected address book that links real people, companies, and emergency groups. It is primarily focused on your trusted emergency groups. Our mission is to reduce the impact of crises everywhere.

In an emergency, get real-time access to all the important people, companies, and services you need - even if you don't know them personally, or if they're not where you expect them to be.

Visit the Saropa Contacts project here: [app.saropa.com](https://app.saropa.com)

PRs, ideas and issues are always welcome! Email for any questions [app.dev.utils@saropa.com](mailto:app.dev.utils@saropa.com)

💙 Saropa

[saropa_link]: https://saropa.com

<!-- Github Repo Link -->
[github_repo_link]: https://github.com/saropa/saropa_dart_utils