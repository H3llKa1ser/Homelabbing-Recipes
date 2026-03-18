# Zero Trust

## Zero Trust Maturity Model

### 1) Initial Objectives

    Cloud identity federates with on-premises identity systems.
    Conditional Access policies gate access and provide remediation activities.
    Analytics improve visibility.

### 2) Additional Objectives

    Identities and access privileges are managed with Identity Governance.
    Device, location, and user behavior are analyzed in real-time to determine risk and deliver ongoing identity protection.
    Integrate threat signals from other security solutions to improve detection, protection, and response.

## Maturity Stages

| Function                  | Traditional                     | Initial                               | Advanced                                                                   | Optimal                                                                                                             |
|---------------------------|----------------------------------|----------------------------------------|-----------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------|
| **Authentication**        | Passwords **or** MFA             | Passwords **with** MFA                 | **Phishing-resistant MFA**                                                  | **Passwordless** enabled<br>Continuous validation                                                                  |
| **Identity Stores**        | **Only** self-managed and on-premises | Self-managed **and** Hosted            | Consolidated<br>Cloud identity federates with on-premises                   | Enterprise-wide identity integration across all partners                                                           |
| **Identity Risk Assessments** | Limited (e.g., identity is compromised) | Manual                                 | Automated<br>**Conditional access policies** gate access and provide remediation actions | Real-time continuous analysis based on **Behavioural Analytics**                                                   |
| **Access Management**      | Permanent access with periodic reviews | Access expires with automated reviews | Need/Session-based access                                                   | Automated authorization for **Just-in-Time** (JIT) and **Just-enough Access** (JEA) tailored to individual actions and resource needs |

## Optimal Zero Trust Maturity Model Example

From: TryHackMe

<img width="1140" height="850" alt="image" src="https://github.com/user-attachments/assets/bf50360a-5526-44f2-bf2e-6d7da91792f9" />
