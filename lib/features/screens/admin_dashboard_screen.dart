import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/startup_verification.dart';
import '../../providers/admin_provider.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() {
    return _AdminDashboardScreenState();
  }
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  String selectedStatus = 'Pending';

  final List<String> statuses = ['Pending', 'Approved', 'Rejected', 'All'];

  void showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void approveStartup(StartupVerificationModel startup) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Approve startup'),
          content: Text(
            'Approve ${startup.startupName} as a recognized ALU startup?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Approve'),
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed != true) {
        return;
      }

      ref
          .read(adminRepositoryProvider)
          .approveStartup(startup.id)
          .then((_) {
            showMessage('${startup.startupName} has been approved.');
          })
          .catchError((error) {
            showMessage('Unable to approve startup: $error');
          });
    });
  }

  void rejectStartup(StartupVerificationModel startup) {
    final reasonController = TextEditingController();

    showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reject startup'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Explain why ${startup.startupName} was rejected.'),
              const SizedBox(height: 14),
              TextField(
                controller: reasonController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Rejection reason',
                  hintText:
                      'Example: Please provide a valid ALU founder email.',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final reason = reasonController.text.trim();

                if (reason.isEmpty) {
                  return;
                }

                Navigator.pop(dialogContext, reason);
              },
              child: const Text('Reject'),
            ),
          ],
        );
      },
    ).then((reason) {
      reasonController.dispose();

      if (reason == null || reason.isEmpty) {
        return;
      }

      ref
          .read(adminRepositoryProvider)
          .rejectStartup(startupId: startup.id, reason: reason)
          .then((_) {
            showMessage('${startup.startupName} has been rejected.');
          })
          .catchError((error) {
            showMessage('Unable to reject startup: $error');
          });
    });
  }

  void moveStartupToPending(StartupVerificationModel startup) {
    ref
        .read(adminRepositoryProvider)
        .moveToPending(startup.id)
        .then((_) {
          showMessage('${startup.startupName} is pending review again.');
        })
        .catchError((error) {
          showMessage('Unable to update startup: $error');
        });
  }

  void signOut() {
    FirebaseAuth.instance.signOut().catchError((error) {
      showMessage('Unable to sign out: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    final startupsAsync = ref.watch(startupVerificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () {
          ref.invalidate(startupVerificationProvider);

          return Future.delayed(const Duration(milliseconds: 500));
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Startup verification',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),

            const SizedBox(height: 7),

            Text(
              'Review startup accounts before allowing them to post opportunities.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 22),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: statuses.map((status) {
                  final isSelected = selectedStatus == status;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(status),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          selectedStatus = status;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 22),

            startupsAsync.when(
              loading: () {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                );
              },
              error: (error, stackTrace) {
                return _AdminMessageCard(
                  icon: Icons.error_outline,
                  title: 'Unable to load startups',
                  message: 'Check your connection and try again.',
                  buttonText: 'Retry',
                  onPressed: () {
                    ref.invalidate(startupVerificationProvider);
                  },
                );
              },
              data: (startups) {
                final filteredStartups = startups.where((startup) {
                  if (selectedStatus == 'All') {
                    return true;
                  }

                  return startup.verificationStatus == selectedStatus;
                }).toList();

                if (filteredStartups.isEmpty) {
                  return _AdminMessageCard(
                    icon: Icons.business_outlined,
                    title: 'No $selectedStatus startups',
                    message: 'There are no startup accounts in this category.',
                  );
                }

                return Column(
                  children: filteredStartups.map((startup) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _StartupVerificationCard(
                        startup: startup,
                        onApprove: () {
                          approveStartup(startup);
                        },
                        onReject: () {
                          rejectStartup(startup);
                        },
                        onMoveToPending: () {
                          moveStartupToPending(startup);
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _StartupVerificationCard extends StatelessWidget {
  final StartupVerificationModel startup;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onMoveToPending;

  const _StartupVerificationCard({
    required this.startup,
    required this.onApprove,
    required this.onReject,
    required this.onMoveToPending,
  });

  Color statusColor(BuildContext context) {
    if (startup.verificationStatus == 'Approved') {
      return Colors.green;
    }

    if (startup.verificationStatus == 'Rejected') {
      return Colors.red;
    }

    return Colors.orange;
  }

  String formatDate(DateTime? date) {
    if (date == null) {
      return 'Unknown date';
    }

    final day = date.day.toString().padLeft(2, '0');

    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final color = statusColor(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  child: Text(
                    startup.startupName.substring(0, 1).toUpperCase(),
                  ),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        startup.startupName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(startup.email),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    startup.verificationStatus,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            _InformationRow(
              label: 'Founder',
              value: startup.founderName.isEmpty
                  ? 'Not provided'
                  : startup.founderName,
            ),

            _InformationRow(
              label: 'ALU email',
              value: startup.founderAluEmail.isEmpty
                  ? 'Not provided'
                  : startup.founderAluEmail,
            ),

            _InformationRow(
              label: 'Location',
              value: startup.location.isEmpty
                  ? 'Not provided'
                  : startup.location,
            ),

            _InformationRow(
              label: 'Website',
              value: startup.website.isEmpty ? 'Not provided' : startup.website,
            ),

            _InformationRow(
              label: 'Registered',
              value: formatDate(startup.createdAt),
            ),

            const SizedBox(height: 12),

            Text(
              startup.description.isEmpty
                  ? 'No startup description was provided.'
                  : startup.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            if (startup.verificationMessage.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  startup.verificationMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],

            const SizedBox(height: 18),

            if (startup.verificationStatus == 'Pending')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: onApprove,
                      child: const Text('Approve'),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onMoveToPending,
                  child: const Text('Move back to Pending'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InformationRow extends StatelessWidget {
  final String label;
  final String value;

  const _InformationRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _AdminMessageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onPressed;

  const _AdminMessageCard({
    required this.icon,
    required this.title,
    required this.message,
    this.buttonText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Icon(icon, size: 45, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
            if (buttonText != null && onPressed != null) ...[
              const SizedBox(height: 14),
              TextButton(onPressed: onPressed, child: Text(buttonText!)),
            ],
          ],
        ),
      ),
    );
  }
}
