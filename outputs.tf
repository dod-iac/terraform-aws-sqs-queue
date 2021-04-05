output "arn" {
  description = "The Amazon Resource Name (ARN) of the queue."
  value       = aws_sqs_queue.main.arn
}

output "url" {
  description = "The url of the queue."
  value       = aws_sqs_queue.main.id
}
